Now we'll generate ignition configs for the nodes that will compose our cluster.

```execute
cd ~/ocpinstall/install
openshift-install create ignition-configs

# Copy the ignition files to the fileserver
sudo cp ~/ocpinstall/install/*.ign /var/www/html/
sudo chown apache:apache /var/www/html/*

# Create ignition config for the bootstrap node
export SEGMENT=$(hostname -I|cut -d. -f3)
cat >merge-bootstrap.ign <<EOF
{
  "ignition": {
    "config": {
      "merge": [
        {
          "source": "http://192.168.${SEGMENT}.10:81/bootstrap.ign",
          "verification": {}
        }
      ]
    },
    "timeouts": {},
    "version": "3.1.0"
  },
  "networkd": {},
  "passwd": {},
  "storage": {},
  "systemd": {}
}
EOF
```

Next we're going to download `govc`, a vSphere CLI tool that will make our lives a bit easier while we create our machines:
```execute
curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | sudo tar -C /usr/local/bin -xvzf - govc
```
Then set some environment variables to configure `govc`:
```execute
export GOVC_URL=portal.vc.opentlc.com
export GOVC_USERNAME=sandbox-%GUID%@vc.opentlc.com
export GOVC_INSECURE=1
```
And add your vSphere password like this:
```
export GOVC_PASSWORD=<your vCenter password>
```