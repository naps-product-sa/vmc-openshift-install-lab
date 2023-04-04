#### Configure bastion for OCP4 UPI
Recall that our bastion will be serving a handful of important functions to allow us to proceed with our install in a constrained environment.

  * **A load balancer to route API and Ingress traffic**. Since we don't have the permission to grant inbound Internet access to hosts we create, we'll route all of our traffic through the bastion host. In order to achieve this, we'll use HAProxy. Check out line 61 in our config file at `ansible/templates/haproxy.j2`:
    ```bash
    frontend api
        bind 192.168.{{ labenv_segment }}.10:6443
        default_backend controlplaneapi
    frontend machineconfig
        bind 192.168.{{ labenv_segment }}.10:22623
        default_backend controlplanemc
    frontend tlsrouter
        bind 192.168.{{ labenv_segment }}.10:443
        default_backend secure
    # frontend insecurerouter
    #     bind 192.168.{{ labenv_segment }}.10:80
    #     default_backend insecure
    ```
    You can see we're listening on port 6443 for the Kubernetes API, 22623 for serving ignition configs, and 443 for application ingress. 
    
    > We've commented out the load balancing for insecure traffic on port 80 because we're currently using it to host this labguide :). This isn't terribly uncommon in customer environments anyway; there are plenty of organizations that require TLS encryption on all HTTP traffic. 
    
    We then route corresponding traffic to the appropriate backends, defined further down in the HAProxy config and described in the OpenShift documentation [here](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/installing-vmc-user-infra.html#installation-load-balancing-user-infra_installing-vmc-user-infra).

  * **A local DNS server to provide hostname resolution within the OpenShift cluster**. We don't have the capacity to create public DNS records, a step that is normally required for `api.<cluster_name>.<base_domain>` and `*.apps.<cluster_name>.<base_domain>` as indicated in the documentation [here](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/installing-vmc-user-infra.html#installation-dns-user-infra_installing-vmc-user-infra). For our lab, we'll use a self-hosted DNS server called BIND. The most important piece of our configuration is defined in `ansible/templates/dynamic.opentlc.com.zone.j2`:
    ```
    $TTL 1D
    @   IN SOA  dns.dynamic.opentlc.com   root.dns.dynamic.opentlc.com. (
                                        2017031330      ; serial
                                        1D              ; refresh
                                        1H              ; retry
                                        1W              ; expire
                                        3H )            ; minimum
    $ORIGIN         dynamic.opentlc.com.
    dynamic.opentlc.com.            IN      NS      dns.dynamic.opentlc.com.
    dns                     IN      A       192.168.{{ labenv_segment }}.10
    *.apps.{{ guid }}     IN    A    192.168.{{ labenv_segment }}.10
    ns1.{{ guid }}     IN    A    192.168.{{ labenv_segment }}.111
    bastion.{{ guid }}     IN    A    192.168.{{ labenv_segment }}.10
    api.{{ guid }}     IN    A    192.168.{{ labenv_segment }}.10
    api-int.{{ guid }}     IN    A    192.168.{{ labenv_segment }}.10
    master-0.{{ guid }}    IN    A    192.168.{{ labenv_segment }}.100
    master-1.{{ guid }}    IN    A    192.168.{{ labenv_segment }}.101
    master-2.{{ guid }}    IN    A    192.168.{{ labenv_segment }}.102
    worker-0.{{ guid }}    IN    A    192.168.{{ labenv_segment }}.200
    worker-1.{{ guid }}    IN    A    192.168.{{ labenv_segment }}.201
    worker-2.{{ guid }}    IN    A    192.168.{{ labenv_segment }}.202
    provision.{{ guid }}    IN    A    192.168.{{ labenv_segment }}.10
    ```
    For all the records we're going to need, we define them as `<role>.<guid>.dynamic.opentlc.com`, and assign each one an IP address after `{{ labenv_segment }}` is expanded to the third octet in ansible. If you want to learn more about using BIND, you can take a look at [this blog](https://www.redhat.com/sysadmin/dns-configuration-introduction).

  * **A file server to host ignition configs**. We'll also need to host ignition configs so that our RHCOS machines can fetch their configuration when they boot up. We'll generate these during the lab exercises and copy them over to an Apache server, which is simple enough to install, configure, and enable with ansible, as we see in `ansible/main.yml`:
    ```
    - name: Install required software
        ansible.builtin.yum:
        name: "{{ item }}"
        state: present
        loop:
        - bind
        - bind-utils
        - httpd
        - haproxy
    ...
    - name: Configure Listen syntax on httpd.conf
        ansible.builtin.replace:
        path: /etc/httpd/conf/httpd.conf
        regexp: 'Listen 80'
        replace: "Listen 192.168.{{ hostname_output.stdout }}.10:81"

    - name: Enable httpd
        ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
    ```

#### Create OpenShift Installation Directory and Prereqs
To get us started, ansible will also create a directory to house the installation materials at `~/ocpinstall/install` and handle a couple installation prereqs for us:
* [Generate an OpenSSH keypair](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/installing-vmc.html#ssh-agent-using_installing-vmc) to facilitate cluster node SSH access.
* [Create an install-config.yaml file](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/installing-vmc-user-infra.html#installation-initializing-manual_installing-vmc-user-infra) to provide relevant configuration to the OpenShift installer. The OpenShift Installer consumes and deletes this file when run, so ansible copies over a backup too. Here's what the template at `ansible/templates/install-config.yaml.j2` looks like:
   ```
   apiVersion: v1
   baseDomain: dynamic.opentlc.com
   compute:
   - architecture: amd64
   hyperthreading: Enabled
   name: worker
   replicas: 0
   controlPlane:
   architecture: amd64
   hyperthreading: Enabled
   name: master
   replicas: 3
   metadata:
   name: {{ guid }}
   platform:
   vsphere:
       datacenter: SDDC-Datacenter
       defaultDatastore: WorkloadDatastore
       diskType: thin
       folder: /SDDC-Datacenter/vm/Workloads/sandbox-{{ guid }}
       password: {{ vcenter_password}}
       username: sandbox-{{ guid }}@{{ vcenter_domain }}
       vCenter: {{ vcenter_hostname }}
   publish: External
   pullSecret: {{ ocp4_pull_secret | to_json }}
   sshKey: '{{ sshKey_content }}'
   ```
   Commentary about what the different fields mean can be found in the documentation [here](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/installing-vmc-user-infra.html#installation-vsphere-config-yaml_installing-vmc-user-infra).
* [Generate Kubernetes manifests](https://docs.openshift.com/container-platform/4.11/installing/installing_vmc/installing-vmc-user-infra.html#installation-user-infra-generate-k8s-manifest-ignition_installing-vmc-user-infra), removing those which aren't required for our install, and disabling schedulable masters:
```
  - name: Create manifests and replace some content
    ansible.builtin.shell:
      cmd: "{{ item }}"
      chdir: "/home/{{ student_name }}/ocpinstall/install/"
    loop:
    - "/usr/local/bin/openshift-install create manifests --dir ~/ocpinstall/install/ --log-level debug"
    - "rm -f openshift/99_openshift-cluster-api_master-machines-*.yaml openshift/99_openshift-cluster-api_worker-machineset-*.yaml"
    - "sed -i 's/mastersSchedulable: true/mastersSchedulable: false/' manifests/cluster-scheduler-02-config.yml"
```