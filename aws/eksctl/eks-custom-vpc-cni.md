* https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/cni-custom-network.html

# 自定义网络
* 查看集群上当前安装的VPC-CNI附加组件版本
```
kubectl describe daemonset aws-node --namespace kube-system | grep amazon-k8s-cni: | cut -d : -f 3
```
* 开启pod自定义网络
```
kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
```

# 按可用区创建配置文件
* vim us-east-1a.yaml
```yml
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata: 
  name: us-east-1a                        # 文件名与此名称保持一致
spec: 
  securityGroups: 
    - sg-0cea1cf2ed938xxxx                # 后缀ClusterSharedNodeSecurityGroup的安全组
  subnet: subnet-0295e90ae9985xxxx        # 对应可用区的子网网络
```
> us-east-1b.yaml,同上
```
kubectl apply -f us-east-1a.yaml
kubectl apply -f us-east-1b.yaml
```
* Pod 在启动的时候会自动根据其可用区来分配相应的网段地址
```
kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone
```

# 开启IP prefix功能
```
kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
kubectl set env ds aws-node -n kube-system WARM_PREFIX_TARGET=1
```

# POD跨vpc访问开启SNAT(不转换pod ip为node主ip)
```
kubectl set env daemonset -n kube-system aws-node AWS_VPC_K8S_CNI_EXTERNALSNAT=true
```

# 重建节点组,使配置生效
```
eksctl get nodegroup --cluster cluster-demo
eksctl delete nodegroup --name ng-1-workers --cluster cluster-demo 
eksctl create nodegroup -f nodegroup-backend.yaml
```