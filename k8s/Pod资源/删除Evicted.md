#批量删除Evicted状态的pod
```
kubectl get pods -n kube-staging | grep Evicted |awk '{print $1}'|xargs kubectl delete pods -n kube-staging
```