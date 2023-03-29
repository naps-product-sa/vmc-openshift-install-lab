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
