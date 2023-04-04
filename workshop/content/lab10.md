Now that you've finished creating your nodes, go ahead and **power them all on** to begin the [bootstrap process](https://docs.openshift.com/container-platform/4.11/architecture/architecture-installation.html#installation-process_architecture-installation). If you've done everything correctly, the **web console** for each host should eventually reach a login prompt. It's normal for the nodes to restart themselves a couple times during this process. 
> If you see anything related to an `Emergency target` in the console output, it's likely that something isn't right. Power the node off and go back and check that your properties are correct.

If everything looks good, run:
```execute
openshift-install wait-for bootstrap-complete --dir ~/ocpinstall/install --log-level=debug
```

This will allow you to follow the progress of the bootstrap process. After a few minutes, you should see something like:
```bash
INFO Waiting up to 20m0s (until 10:30AM) for the Kubernetes API at https://api.dd4sw.dynamic.opentlc.com:6443... 
INFO API v1.24.0+dc5a2fd up 
```
This means your Kubernetes API is up! You should be able to send requests to it to inspect resources as they are created. The installer creates a kubeconfig for you, which you can use like this:
```execute
export KUBECONFIG=~/ocpinstall/install/auth/kubeconfig

oc whoami
oc get nodes
```

If you terminated your `wait-for bootstrap-complete` command, go ahead and run it again:
```execute
openshift-install wait-for bootstrap-complete --dir ~/ocpinstall/install --log-level=debug
```
After some time, you should see something like:
```bash
INFO Waiting up to 30m0s (until 10:40AM) for bootstrapping to complete... 
DEBUG Bootstrap status: complete                   
INFO It is now safe to remove the bootstrap resources 
```
You read that right! It's now safe to obliterate your **bootstrap** machine. The installation is not finished though, the cluster still has work to do. As nodes join into the cluster, they issue certificate-signing requests (CSRs) that must be approved before the installation can complete. About 5 minutes after the bootstrap is finished, there should be a couple of requests pending, which you can approve like this:
```execute
for i in `oc get csr --no-headers | grep -i pending |  awk '{ print $1 }'`; do oc adm certificate approve $i; done
```

About 3 minutes later, there will be another request or two, so we'll run that command again:
```execute
for i in `oc get csr --no-headers | grep -i pending |  awk '{ print $1 }'`; do oc adm certificate approve $i; done
```
Once that's done, our install is nearly complete! We can watch its progress by running:
```execute
openshift-install wait-for install-complete --dir ~/ocpinstall/install --log-level=debug
```
