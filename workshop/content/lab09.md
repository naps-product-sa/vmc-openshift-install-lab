Next we'll build 2 compute nodes. Aside from requiring unique hostnames and IP addresses, these hosts must use the worker ignition config.

#### worker0
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `worker0.%GUID%.dynamic.opentlc.com`
* In Step 8, adjust the following settings in **Virtual Hardware**:
   * CPU: 2
   * Memory: 8 GB
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```execute
        cat ~/ocpinstall/install/worker.ign | base64 -w0 && echo
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```execute
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.200::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```

#### worker1
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `worker1.%GUID%.dynamic.opentlc.com`
* In Step 8, adjust the following settings in **Virtual Hardware**:
   * CPU: 2
   * Memory: 8 GB
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```execute
        cat ~/ocpinstall/install/worker.ign | base64 -w0 && echo
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```execute
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.201::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```
