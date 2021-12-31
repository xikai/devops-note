* 获取节点所有pod的事件
```
kubectl get events -n test --watch
```


# k8s资源使用情况
* 查看节点资源使用情况
```
kubectl top node
```
* 按pod内存使用大小排序
```
kubectl top pod --all-namespaces |sort -k 4 -nr
```