Next we'll create the bootstrap node, which will help facilitate the install and can be deleted once the install is complete.

1. Right click on the **coreos** VM Template and select **Clone -> Clone to Virtual Machine...**
2. Specify `bootstrap.%GUID%.dynamic.opentlc.com` for the Virtual machine name.
3. Select your sandbox-%GUID% folder for the location:
   ```
   portal.vc.opentlc.com
   -> SDDC-Datacenter
      -> Workloads
         -> sandbox-%GUID%
    ```
4. Accept the default compute resource in section 2, and select **Next**.
5. Select the **WorkloadDatastore** for section 3, then click **Next**.
6. Accept the remaining defaults, then click **Finish** to create the Virtual Machine.
7. Right click on the newly created VM (bootstrap.%GUID%.dynamic.opentlc.com) and select **Edit Settings...**
8. Adjust the following settings in **Virtual Hardware**:
   * CPU: 4
   * Memory: 16 GB
9. Switch to **Advanced Parameters** and add the following attribute/value pairs. The values are derived from running the indicated commands on your bastion.
   * `guestinfo.ignition.config.data`: 
        ```execute
        cat ~/ocpinstall/install/merge-bootstrap.ign | base64 -w0 && echo
        ```
   * `guestinfo.afterburn.initrd.network-kargs`:
        ```execute
        export SEGMENT=$(hostname -I|cut -d. -f3)
        echo "ip=192.168.${SEGMENT}.99::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"
        ```
