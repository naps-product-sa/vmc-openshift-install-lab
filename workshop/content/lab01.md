This workshop leverages the [VMware Cloud Open Environment Service](https://demo.redhat.com/catalog?search=vmware&category=Open_Environments&item=babylon-catalog-prod%2Fvmc.sandbox.prod) in the [Red Hat Demo Platform (RHDP)](https://demo.redhat.com) for a UPI installation of OpenShift.

## Understanding the Lab Environment
Before we begin the hands-on portion of the lab, let's take a moment to understand the environment we'll be using today.

### VMC vs vSphere
[VMware Cloud on AWS (VMC)](https://vmc.techzone.vmware.com/vmc-arch/docs/introduction/vmc-aws-a-technical-overview) is a managed cloud offering that provides dedicated VMware vSphere-based Software Defined Data Centers (SDDC) that are hosted within AWS facilities. The solution was designed to create an easy migration path from the datacenter to the cloud and prevent vSphere admins from having to learn to use a new virtualization provider. Both vSphere and VMC SDDCs can be managed with vCenter and the [govc CLI](https://github.com/vmware/govmomi/tree/main/govc), creating a similar experience between the two platforms.

This works to our advantage for this lab, since cloud-based environments offer better scalability than on-prem ones. Even though we'll be working in a VMC environment today, you should be able to commute most of what you learn to vSphere on-prem engagements. We'll be sure to point out any nuances we encounter that are specific to VMC along the way.

### Lab Architecture
The VMware Cloud Open Environment service gives us a few things:
1. A bastion host running RHEL8 on VMC, with SSH access via username/password.
2. VCenter portal access, with a sandbox user account. This user has limited access to a folder named **Workloads/sandbox-%GUID%**
3. Wildcard DNS pointing to your bastion with the record: `*.%GUID%.dynamic.opentlc.com`

This lab is designed to work within those constraints to offer participants the opportunity to build experience installing OpenShift 4 in a VMware environment. Because our sandbox user has limited permissions, we're not going to be able to use [installer-provisioned infrastructure (IPI)](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/preparing-to-install-on-vmc.html#installer-provisioned-method-to-install-ocp-on-vmc). If we were, we could leverage [these awesome scripts](https://gist.github.com/johnsimcall/69e7e7de04130c59c9bd51adbf9d9a2a) to grant the necessary privileges and then let the OpenShift installer handle pretty much everything else. Instead, we're going to use [user-provisioned infrastructure (UPI)](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/installing-vmc-user-infra.html). On the bright side, this lab will give you a better understanding of the nuts and bolts of the install, and prepare you for customer environments where granting the permissions required for IPI is not achievable.

In order to build our cluster, we're going to setup a few things on the bastion host:
* A load balancer to route API and Ingress traffic.
* A local DNS server to provide hostname resolution within the OpenShift cluster.
* A file server to host ignition configs.

Fortunately, we've written some ansible to handle these pre-reqs for you. Let's get started!