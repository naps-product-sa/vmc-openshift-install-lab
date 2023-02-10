# VMC OpenShift Install Lab
This repository is intended to prepare a [VMware Cloud Open Environment Service](https://demo.redhat.com/catalog?search=vmware&category=Open_Environments&item=babylon-catalog-prod%2Fvmc.sandbox.prod) in the [Red Hat Demo Platform (RHDP)](https://demo.redhat.com) for a UPI installation of OpenShift.

## Understanding the Lab Environment
Before we begin the hands-on portion of the lab, let's take a moment to understand the environment we'll be using today.

### VMC vs vSphere
[VMware Cloud on AWS (VMC)](https://vmc.techzone.vmware.com/vmc-arch/docs/introduction/vmc-aws-a-technical-overview) is a managed cloud offering that provides dedicated VMware vSphere-based Software Defined Data Centers (SDDC) that are hosted within AWS facilities. The solution was designed to create an easy migration path from the datacenter to the cloud since vSphere admins wouldn't have to learn to use a new virtualization provider. Both vSphere and VMC SDDCs can be managed with vCenter and the [govc CLI](https://github.com/vmware/govmomi/tree/main/govc), creating a similar experience between the two platforms.

This works to our advantage for this lab, since cloud-based environments offer better scalability than on-prem ones. Even though we'll be working in a VMC environment today, you should be able to commute most of what you learn to vSphere on-prem engagements. We'll be sure to point out any nuances we encounter that are specific to VMC along the way.

### Lab Architecture
The VMware Cloud Open Environment service gives us a few things:
1. A bastion host running RHEL8 on VMC, with SSH access via username/password.
2. VCenter portal access, with a sandbox user account. This user has limited access to a folder named **Workloads/sandbox-${guid}**
3. Wildcard DNS pointing to your bastion with the record: `*.${guid}.dynamic.opentlc.com`

This lab is designed to work within those constraints to offer participants the opportunity to build experience installing OpenShift 4 in a VMware environment. Because our sandbox user has limited permissions, we're not going to be able to use [installer-provisioned infrastructure (IPI)](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/preparing-to-install-on-vmc.html#installer-provisioned-method-to-install-ocp-on-vmc). If we were, we could leverage [these awesome scripts](https://gist.github.com/johnsimcall/69e7e7de04130c59c9bd51adbf9d9a2a) to grant the necessary privileges and then let the OpenShift installer handle pretty much everything else. Instead, we're going to leverage [user-provisioned infrastructure (UPI)](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/installing-vmc-user-infra.html). On the bright side, this lab will give you a better understanding of the nuts and bolts of the install, and prepare you for customer environments where granting the permissions required for IPI are not achievable.

In order to build our cluster, we're going to setup a few things on the bastion host:
* A proxy to route API and Ingress traffic.
* A local DNS server to provide hostname resolution within the OpenShift cluster.
* A file server to host ignition configs.

Fortunately, we've written some ansible to handle these pre-reqs for you. Let's get started!

## Preparing the Lab Environment
Now we're going to run some ansible to prepare our lab environment to install OpenShift using UPI.

### Configure your inventory file
Let's start by fixing the hostname in your `ansible/inventory` file so that it contains the actual hostname of your bastion in VMC. Right now it looks like this:
```bash
[bastions]
bastion.${GUID}.dynamic.opentlc.com   ansible_user=lab-user ansible_password=${PASSWORD}
```
1. Replace the `${GUID}` with the guid of your RHDP deployment. It should be something like `dd4sa`.
2. Replace the `${PASSWORD}` with your SSH password.

Now your `ansible/inventory` file should look something like this:
```bash
[bastions]
bastion.dd4sa.dynamic.opentlc.com   ansible_user=lab-user    ansible_password=3L95nnTWuqgk
```

Let's test that you've done this correctly by running an ad-hoc command against your bastions host group:
```bash
ansible bastions -i ansible/inventory -a 'echo hi'
```
The output should look something like:
```bash
bastion.dd4sa.dynamic.opentlc.com | CHANGED | rc=0 >>
hi
```

### Update your vars file
Next let's add some properties to `ansible/vars.yml`. We're interested in this section:
```bash
###### YOUR PROPERTIES HERE ######
guid: CHANGEME #(e.g. dd4sa)
vcenter_password: CHANGEME
ocp4_pull_secret: 'CHANGEME'
##################################
```
1. Replace the existing values for the guid and vcenter password you got from RHDP
2. Grab your OpenShift Pull Secret from the [Red Hat Hybrid Cloud Console](https://console.redhat.com/openshift/install/vsphere/agent-based) and paste it *between the single ticks* for the `ocp4_pull_secret` variable.

### Run the configuration playbook
Now we should be ready to run our playbook!
```bash
ansible-playbook -i ansible/inventory ansible/main.yml
```

## Installing OpenShift
Now we're ready to install OpenShift!

### Create a VM Template in VCenter
1. To start your installation, you'd normally head over to [The Red Hat Hybrid Cloud Console](https://console.redhat.com/openshift/install/vsphere/user-provisioned) and click **Download RHCOS OVA** to grab the latest RHEL CoreOS OVA template. For this lab, we're going to use 4.11.9, which you can download directly by clicking [this link](https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.11/4.11.9/rhcos-vmware.x86_64.ova).

2. Then go to VCenter, right click on your **Workloads/sandbox-${guid}** folder, and select **Deploy OVF Template...**
3. Select **Local File** and provide the OVA you just downloaded.
   > We can't use the URL directly here because VCenter throws a Peer not authenticated error when requesting the OVA from the OpenShift mirror site.
4. Accept the defaults for sections 2-4 of the wizard, and then select **WorkloadDatastore** for storage in section 5
5. Click Next and Finish to complete the template creation. It will take a few minutes to upload and deploy.
6. Once the template has finished uploading, right click on it (**coreos**), and select **Edit Settings...**
7. Switch to **Advanced Parameters** and add the following:
   * Attribute: `guestinfo.ignition.config.data.encoding`
   * Value: `base64`

### Generate ignition configs
Now we'll generate ignition configs for the nodes that will compose our cluster.

```bash
ssh lab-user@bastion.GUID.dynamic.opentlc.com

cd ~/ocpinstall/install
openshift-install create ignition-configs

# Copy the ignition files to the fileserver
sudo cp ~/ocpinstall/install/*.ign /var/www/html/
sudo chown apache:apache /var/www/html/*

# Create ignition config for the bootstrap node
export SEGMENT=$(hostname -I|cut -d. -f3)
cat >merge-bootstrap.ign <<EOF
{
  "ignition": {
    "config": {
      "merge": [
        {
          "source": "http://192.168.${SEGMENT}.10:81/bootstrap.ign",
          "verification": {}
        }
      ]
    },
    "timeouts": {},
    "version": "3.1.0"
  },
  "networkd": {},
  "passwd": {},
  "storage": {},
  "systemd": {}
}
EOF
```

### Create the temporary bootstrap node
Next we'll create the bootstrap node, which will help facilitate the install and can be deleted once the install is complete.

1. Right click on the **coreos** VM Template and select **Clone -> Clone to Virtual Machine...**
2. Specify `bootstrap.GUID.dynamic.opentlc.com` for the Virtual machine name, replacing `GUID` with your guid from RHDP.
3. Select your sandbox-GUID folder for the location:
   ```
   portal.vc.opentlc.com
   -> SDDC-Datacenter
      -> Workloads
         -> sandbox-GUID
    ```
4. Accept the default compute resource in section 2, and select **Next**.
5. Select the **WorkloadDatastore** for section 3, then click **Next**.
6. Accept the remaining defaults, then click **Finish** to create the Virtual Machine.
7. Right click on the newly created VM (master0.GUID.dynamic.opentlc.com) and select **Edit Settings...**
8. Adjust the following settings in **Virtual Hardware**:
   * CPU: 4
   * Memory: 16 GB
9. Switch to **Advanced Paramters** and add the following attribute/value pairs. The values are derived from running the indicated commands on your bastion.
   * `guestinfo.ignition.config.data`: 
        ```bash
        cat ~/ocpinstall/install/merge-bootstrap.ign | base64 -w0
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```bash
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.99::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```

### Create the control plane nodes
Next we'll build 3 control plane nodes. Aside from requiring unique hostnames and IP addresses, these hosts must use the master ignition config.

#### master0
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `master0.GUID.dynamic.opentlc.com`
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```bash
        cat ~/ocpinstall/install/master.ign | base64 -w0
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```bash
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.100::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```

#### master1
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `master1.GUID.dynamic.opentlc.com`
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```bash
        cat ~/ocpinstall/install/master.ign | base64 -w0
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```bash
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.101::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```

#### master2
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `master2.GUID.dynamic.opentlc.com`
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```bash
        cat ~/ocpinstall/install/master.ign | base64 -w0
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```bash
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.102::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```

### Create the compute nodes
Next we'll build 2 compute nodes. Aside from requiring unique hostnames and IP addresses, these hosts must use the worker ignition config.

#### worker0
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `worker0.GUID.dynamic.opentlc.com`
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```bash
        cat ~/ocpinstall/install/worker.ign | base64 -w0
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```bash
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.200::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```

#### worker1
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `worker1.GUID.dynamic.opentlc.com`
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```bash
        cat ~/ocpinstall/install/worker.ign | base64 -w0
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```bash
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.201::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```