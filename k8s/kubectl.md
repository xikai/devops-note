* https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands

* 查看指定节点的标签
```
kubectl get nodes --show-labels -l name=front-b
kubectl describe node -l name=training |grep Hostname
```
```
kubectl run -it busybox --image=busybox -n prod
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

# [jsonpath格式输出](https://kubernetes.io/zh-cn/docs/reference/kubectl/jsonpath/)
