Next we'll build 3 control plane nodes. Aside from requiring unique hostnames and IP addresses, these hosts must use the master ignition config.

#### master0
Clone a new VM from the **coreos** template in the same way that was done for the bastion. For the virtual machine name, use:
```copy
master0.%GUID%.dynamic.opentlc.com
```
Then use govc to configure this VM:
```execute
# Get base64-encoded config data
export CONFIG_DATA=$(cat ~/ocpinstall/install/master.ign | base64 -w0)

# Get IP address and nameserver
export SEGMENT=$(hostname -I|cut -d. -f3)
export IPCFG="ip=192.168.${SEGMENT}.100::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"

# Update Settings, and allocate 4CPU and 16GB RAM
govc vm.change -vm=master0.%GUID%.dynamic.opentlc.com \
              -c=4 \
              -m 16384 \
              -e="guestinfo.ignition.config.data.encoding=base64" \
              -e="guestinfo.ignition.config.data=${CONFIG_DATA}" \
              -e="guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
```

#### master1
Clone another VM with the name:
```copy
master1.%GUID%.dynamic.opentlc.com
```
Then configure it with `govc`:
```execute
# Get base64-encoded config data
export CONFIG_DATA=$(cat ~/ocpinstall/install/master.ign | base64 -w0)

# Get IP address and nameserver
export SEGMENT=$(hostname -I|cut -d. -f3)
export IPCFG="ip=192.168.${SEGMENT}.101::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"

# Update Settings, and allocate 4CPU and 16GB RAM
govc vm.change -vm=master1.%GUID%.dynamic.opentlc.com \
              -c=4 \
              -m 16384 \
              -e="guestinfo.ignition.config.data.encoding=base64" \
              -e="guestinfo.ignition.config.data=${CONFIG_DATA}" \
              -e="guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
```

#### master2
Clone another VM with the name:
```copy
master2.%GUID%.dynamic.opentlc.com
```
Then configure it with `govc`:
```execute
# Get base64-encoded config data
export CONFIG_DATA=$(cat ~/ocpinstall/install/master.ign | base64 -w0)

# Get IP address and nameserver
export SEGMENT=$(hostname -I|cut -d. -f3)
export IPCFG="ip=192.168.${SEGMENT}.102::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"

# Update Settings, and allocate 4CPU and 16GB RAM
govc vm.change -vm=master2.%GUID%.dynamic.opentlc.com \
              -c=4 \
              -m 16384 \
              -e="guestinfo.ignition.config.data.encoding=base64" \
              -e="guestinfo.ignition.config.data=${CONFIG_DATA}" \
              -e="guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
```
