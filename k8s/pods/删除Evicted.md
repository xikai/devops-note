* 批量删除Evicted状态的pod
```
kubectl get pods -n kube-staging | grep Evicted |awk '{print $1}'|xargs kubectl delete pods -n kube-staging
```

* 强制删除pod (--grace-period=0 --force)
```
kubectl delete pods httpd-app-6df58645c6-cxgcm --grace-period=0 --force
```