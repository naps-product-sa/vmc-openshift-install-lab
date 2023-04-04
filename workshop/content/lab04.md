Now that that's out of the way, let's run the playbook.
```execute
ansible-playbook ansible/main.yml
```
After it completes, let's check a few hostnames to make sure our DNS is working properly. `api.%GUID%.dynamic.opentlc.com` and `*.apps.%GUID%.dynamic.opentlc.com` should both point to the bastion (our load balancer):
```execute
dig +short api.%GUID%.dynamic.opentlc.com
dig +short *.apps.%GUID%.dynamic.opentlc.com
```

And we need unique IPs for each master and worker node
```execute
dig +short master-0.%GUID%.dynamic.opentlc.com
dig +short master-1.%GUID%.dynamic.opentlc.com
dig +short master-2.%GUID%.dynamic.opentlc.com
dig +short worker-0.%GUID%.dynamic.opentlc.com
dig +short worker-1.%GUID%.dynamic.opentlc.com
```
You should see `dig` return a valid IP address for each hostname. If not, try running `sudo systemctl restart named` and check again.

Now we're ready to install OpenShift!
