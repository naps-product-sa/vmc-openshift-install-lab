# VMC OpenShift Install Lab
This repository is intended to leverage the [VMware Cloud Open Environment Service](https://demo.redhat.com/catalog?search=vmware&category=Open_Environments&item=babylon-catalog-prod%2Fvmc.sandbox.prod) in the [Red Hat Demo Platform (RHDP)](https://demo.redhat.com) for a UPI installation of OpenShift.

## Deploy the labguide
First, SSH into your bastion:
```bash
ssh lab-user@bastion.<your guid>.dynamic.opentlc.com
```

Then fire up a container with `podman`:
```bash
sudo podman run -d -p 80:10080 -e GUID=<your guid> -e TERMINAL_TAB=split quay.io/akrohg/vmc-openshift-install-dashboard
```

Now you should be able to view your labguide in the browser:
```bash
http://bastion.<your guid>.dynamic.opentlc.com
```