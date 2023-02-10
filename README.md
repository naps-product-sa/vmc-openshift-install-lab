# VMC OpenShift Install Lab
This repository is intended to prepare a [VMware Cloud Open Environment Service](https://demo.redhat.com/catalog?search=vmware&category=Open_Environments&item=babylon-catalog-prod%2Fvmc.sandbox.prod) in [RHDP](https://demo.redhat.com) for a UPI installation of OpenShift.

## Understanding the Lab Environment
The VMware Cloud Open Environment service gives us a few things:
1. A bastion host running RHEL8, with SSH access via username/password.
2. VCenter portal access, with a sandbox user account. This user has limited access to a folder named **Workloads/sandbox-${guid}**
3. Wildcard DNS pointing to your bastion with the record: `*.${guid}.dynamic.opentlc.com`

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
Next we'll build 3 control plane nodes.



### Create the compute nodes