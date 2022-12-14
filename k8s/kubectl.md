* 查看指定节点的标签
```
kubectl get nodes --show-labels -l name=front-b
```
```
kubectl -n prod run -it busybox --image=busybox
```

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
* 查看指定工作节点己使用的资源
```
kubectl describe node -l name=backend-c |grep -A 10 "Allocated resources:"
```