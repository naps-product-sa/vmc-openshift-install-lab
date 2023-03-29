Next we'll build 3 control plane nodes. Aside from requiring unique hostnames and IP addresses, these hosts must use the master ignition config.

#### master0
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `master0.%GUID%.dynamic.opentlc.com`
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```execute
        cat ~/ocpinstall/install/master.ign | base64 -w0 && echo
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```execute
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.100::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```

#### master1
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `master1.%GUID%.dynamic.opentlc.com`
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```execute
        cat ~/ocpinstall/install/master.ign | base64 -w0 && echo
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```execute
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.101::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```

#### master2
Repeat the procedure for the bootstrap node, with the following differences:
* Virtual machine name: `master2.%GUID%.dynamic.opentlc.com`
* In Step 9:
   * `guestinfo.ignition.config.data`: 
        ```execute
        cat ~/ocpinstall/install/master.ign | base64 -w0 && echo
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```execute
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.102::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```
