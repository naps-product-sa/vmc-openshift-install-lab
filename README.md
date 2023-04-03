# VMC OpenShift Install Lab
This repository is intended to leverage the [VMware Cloud Open Environment Service](https://demo.redhat.com/catalog?search=vmware&category=Open_Environments&item=babylon-catalog-prod%2Fvmc.sandbox.prod) in the [Red Hat Demo Platform (RHDP)](https://demo.redhat.com) for a UPI installation of OpenShift.

## Deploy the labguide
The labguide for this workshop is built using [OpenShift Homeroom](https://github.com/openshift-homeroom). You can run it in a container on your bastion host and access it using your browser. First, SSH into your bastion:
```bash
export GUID=<your guid>

ssh lab-user@bastion.$GUID.dynamic.opentlc.com
```

Then fire up a container with `podman`:
```bash
export GUID=<your guid>

sudo podman run -d -p 80:10080 -e GUID=$GUID quay.io/akrohg/vmc-openshift-install-dashboard
```

Now you should be able to view your labguide in the browser:
```bash
http://bastion.<your guid>.dynamic.opentlc.com
```