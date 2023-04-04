When the installation is completed, the installer will output your console URL and `kubeadmin` credentials at the end of the log. It will look something like this:
```bash
INFO Install complete!
INFO To access the cluster as the system:admin user when using 'oc', run
INFO     export KUBECONFIG=/home/lab-user/ocpinstall/install/auth/kubeconfig
INFO Access the OpenShift web-console here: https://console-openshift-console.apps.mlwvc.dynamic.opentlc.com
INFO Login to the console with user: "kubeadmin", and password: "xrujv-KJ7Ao-i4uHC-mqgKv"
INFO Time elapsed: 0s
```
Pop open the URL in your browser and login with the credentials provided.

You did it! You successfully installed OpenShift on VMware. Feel free to browse around a bit. Note that some functionality (like provisioning storage) may be limited since our VMware service account doesn't have full permissions. You also won't be able to create insecure routes on port 80 because we removed that binding from our load balancer.
