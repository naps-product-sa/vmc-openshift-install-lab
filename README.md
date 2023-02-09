# VMC OpenShift Install Lab
This repository is intended to prepare a [VMware Cloud Open Environment Service](https://demo.redhat.com/catalog?search=vmware&category=Open_Environments&item=babylon-catalog-prod%2Fvmc.sandbox.prod) in [RHDP](https://demo.redhat.com) for a UPI installation of OpenShift.

## Understanding the Lab Environment
The VMware Cloud Open Environment service gives us a few things:
1. A bastion host running RHEL9, with SSH access via username/password.
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