* https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands

* 查看指定节点的标签
```
kubectl get nodes --show-labels -l name=front-b
kubectl describe node -l name=training |grep Hostname
```
```
kubectl run -it alpine --image=alpine -n prod
```

* 获取节点所有pod的事件
```
kubectl get events -n test --watch
```


# k8s资源使用情况
* 查看节点资源使用情况
```
kubectl top nodes
kubectl top nodes -l name=front-c
```
* 按pod cpu内存使用大小排序
```
kubectl top nodes --sort-by=cpu
kubectl top nodes --sort-by=memory
kubectl top pod --all-namespaces |sort -k 4 -nr
```
* 查看指定工作节点己使用的资源
```
kubectl describe node -l name=backend-c |grep -A 10 "Allocated resources:"
```

# resources
```
kubectl set resources deployment nginx --limits=cpu=200m,memory=512Mi --requests=cpu=100m,memory=256Mi
```

# replicas scale
```
kubectl scale deployment/nginx-deployment --replicas=10
```
# hpa scale
```
kubectl autoscale deployment/nginx-deployment --min=10 --max=15 --cpu-percent=80
```

# 手动均衡pod
```
kubectl cordon ip-172-31-119-7.cn-northwest-1.compute.internal
kubectl get pod -n test -owide|grep ip-172-31-120-6 |awk '{print $1}' |head |xargs kubectl delete pods -n test
kubectl get pod -n test -owide|grep ip-172-31-88-116 |awk '{print $1}' |head |xargs kubectl delete pods -n test
kubectl get pod -n test -owide|grep ip-172-31-89-163 |awk '{print $1}' |head |xargs kubectl delete pods -n test
kubectl uncordon ip-172-31-119-7.cn-northwest-1.compute.internal
```

# 删除pod
* 删除特定命名空间的异常 Pod
```
kubectl delete pods -n <namespace> --field-selector=status.phase!=Running
```

* 批量删除Evicted状态的pod
```
kubectl get pods -n <namespace> | grep Evicted |awk '{print $1}'|xargs kubectl delete pods -n <namespace>
```

* 强制删除pod (--grace-period=0 --force)
```
kubectl delete pods httpd-app-6df58645c6-cxgcm --grace-period=0 --force
```

# [jsonpath格式输出](https://kubernetes.io/zh-cn/docs/reference/kubectl/jsonpath/)
