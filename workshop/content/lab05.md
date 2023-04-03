1. To start your installation, you'd normally head over to [The Red Hat Hybrid Cloud Console](https://console.redhat.com/openshift/install/vsphere/user-provisioned) and click **Download RHCOS OVA** to grab the latest RHEL CoreOS OVA template. For this lab, we're going to use 4.11.9, which you can download directly by clicking [this link](https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.11/4.11.9/rhcos-vmware.x86_64.ova).

2. Then go to [vCenter](https://portal.vc.opentlc.com/ui/app/search?query=bastion&searchType=simple), right click on your **Workloads/sandbox-%GUID%** folder, and select **Deploy OVF Template...**
3. Select **Local File** and provide the OVA you just downloaded.
   > We can't use the URL directly here because vCenter throws a Peer not authenticated error when requesting the OVA from the OpenShift mirror site.
4. Accept the defaults for sections 2-4 of the wizard, and then select **WorkloadDatastore** for storage in section 5
5. Click Next and Finish to complete the template creation. It will take a few minutes to upload and deploy.
