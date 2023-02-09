# VMC OpenShift Install Lab
This repository is intended to prepare a [VMware Cloud Open Environment Service](https://demo.redhat.com/catalog?search=vmware&category=Open_Environments&item=babylon-catalog-prod%2Fvmc.sandbox.prod) in [RHDP](https://demo.redhat.com) for a UPI installation of OpenShift.

## Configure your inventory file
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
bastion.dd4sw.dynamic.opentlc.com | CHANGED | rc=0 >>
hi
```