Next we'll build 2 compute nodes. Aside from requiring unique hostnames and IP addresses, these hosts must use the worker ignition config.

#### worker0
Clone another VM with the name:
```copy
worker0.%GUID%.dynamic.opentlc.com
```
Then configure it with `govc`:
```execute
# Get base64-encoded config data
export CONFIG_DATA=$(cat ~/ocpinstall/install/worker.ign | base64 -w0)

# Get IP address and nameserver
export SEGMENT=$(hostname -I|cut -d. -f3)
export IPCFG="ip=192.168.${SEGMENT}.200::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"

# Update Settings, and allocate 2CPU and 8GB RAM
govc vm.change -vm=worker0.%GUID%.dynamic.opentlc.com \
              -c=2 \
              -m=8192  \
              -e="guestinfo.ignition.config.data.encoding=base64" \
              -e="guestinfo.ignition.config.data=${CONFIG_DATA}" \
              -e="guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
```

#### worker1
Clone another VM with the name:
```copy
worker1.%GUID%.dynamic.opentlc.com
```
Then configure it with `govc`:
```execute
# Get base64-encoded config data
export CONFIG_DATA=$(cat ~/ocpinstall/install/worker.ign | base64 -w0)

# Get IP address and nameserver
export SEGMENT=$(hostname -I|cut -d. -f3)
export IPCFG="ip=192.168.${SEGMENT}.201::192.168.${SEGMENT}.1:255.255.255.0:::none nameserver=192.168.${SEGMENT}.10"

# Update Settings, and allocate 2CPU and 8GB RAM
govc vm.change -vm=worker1.%GUID%.dynamic.opentlc.com \
              -c=2 \
              -m=8192  \
              -e="guestinfo.ignition.config.data.encoding=base64" \
              -e="guestinfo.ignition.config.data=${CONFIG_DATA}" \
              -e="guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
```
