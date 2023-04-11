# VMC OpenShift Install Lab
This repository is intended to leverage the VMware Cloud Open Environment Service in the [Red Hat Demo Platform (RHDP)](https://demo.redhat.com) for a UPI installation of OpenShift. If you haven't already, go ahead and [request the service](https://demo.redhat.com/catalog?search=vmware&category=Open_Environments&item=babylon-catalog-prod%2Fvmc.sandbox.prod), then proceed with the steps below to spin up the labguide. An example can be viewed [here](http://vmc-lab.rhkrohg.link:8080/workshop/lab01).

## Deploy the labguide
The labguide for this workshop is built using [OpenShift Homeroom](https://github.com/openshift-homeroom). It serves up the workshop instructions in markdown alongside a web terminal. You can run it in a container on your bastion host and access it using your browser. 
1. Set an environment variable with the GUID from your RHDP deployment:
   ```bash
   export GUID=<your guid>
   ```
2. Then ssh into your bastion:
   ```bash
   ssh lab-user@bastion.$GUID.dynamic.opentlc.com
   ```
3. Set an environment variable with your GUID once more, this time on the bastion host:
   ```bash
   export GUID=<your guid>
   ```
4. Fire up a container with `podman`:
   ```bash
   sudo podman run -d -p 80:10080 -e GUID=$GUID quay.io/akrohg/vmc-openshift-install-dashboard
   ```
5. Now you should be able to view your labguide in the browser:
   ```bash
   http://bastion.<your guid>.dynamic.opentlc.com
   ```