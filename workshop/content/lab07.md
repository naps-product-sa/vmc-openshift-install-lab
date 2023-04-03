Next we'll create the bootstrap node, which will help facilitate the install and can be deleted once the install is complete.

1. Right click on the **coreos** VM Template and select **Clone -> Clone to Virtual Machine...**
2. For the Virtual machine name, specify:
   ```copy
   bootstrap.%GUID%.dynamic.opentlc.com
   ```
3. Select your sandbox-%GUID% folder for the location:
   ```
   portal.vc.opentlc.com
   -> SDDC-Datacenter
      -> Workloads
         -> sandbox-%GUID%
   ```
   > If you fail to use the correct location here, your VM will disappear as soon as you create it because you don't have permission to see it.
4. Accept the default compute resource in section 2, and select **Next**.
5. Select the **WorkloadDatastore** for section 3, then click **Next**.
6. Accept the remaining defaults, then click **Finish** to create the Virtual Machine.
7. Let's use `govc` to configure this VM:
   ```execute
   # Get base64-encoded config data
   export CONFIG_DATA=$(cat ~/ocpinstall/install/merge-bootstrap.ign | base64 -w0)

   # Get IP address and nameserver
   export SEGMENT=$(hostname -I|cut -d. -f3)
   export IPCFG="ip=192.168.${SEGMENT}.99::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"

   # Update settings, and allocate 4CPU and 16GB RAM
   govc vm.change -vm=bootstrap.%GUID%.dynamic.opentlc.com \
                  -c=4 \
                  -m 16384 \
                  -e="guestinfo.ignition.config.data.encoding=base64" \
                  -e="guestinfo.ignition.config.data=${CONFIG_DATA}" \
                  -e="guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
   ```

