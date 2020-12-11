* 节点维护并驱逐pod
```
#cordon将某个node隔离脱离调度范围,在其上运行的pod不会自动停止
kubectl cordon k8s-node-1

#驱逐已经运行的pod
kubectl drain k8s-node-1 --ignore-daemonsets --delete-local-data

#维护完成后恢复node调度
kubectl uncordon k8s-node-1
#如果想删除node 节点，则进行这个步骤
kubectl delete node k8s-node-1


```

* 更新资源对象的label
```
#添加label
kubectl label pod redis-master-bobr0 role=backend
#查看pod的label
kubectl get pods -Lrole
#删除label(在指定label的key名并与一个减号)
kubectl label pod redis-master-bobr0 role-
```