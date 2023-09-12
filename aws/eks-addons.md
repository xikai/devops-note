* https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/eks-networking-add-ons.html

>附加组件是为 Kubernetes 应用程序提供辅助操作功能的软件，但并不特定于应用程序。这包括可观测性代理或 Kubernetes 驱动程序等软件，这些软件允许集群与用于联网、计算和存储的底层 AWS 资源进行交互。附加组件软件通常由 Kubernetes 社区、AWS 等云提供商或第三方供应商构建和维护。`Amazon EKS 会自动为每个集群安装自我管理的附加组件，例如 Amazon VPC CNI plugin for Kubernetes、kube-proxy 和 CoreDNS`。您可以更改附加组件的默认配置并在需要时加以更新。

* 查看集群上当前安装的附加组件类型
```sh
aws eks describe-addon --cluster-name my-cluster --addon-name vpc-cni --query addon.addonVersion --output text
#如果返回来的是版本号，则表明您的集群上安装有 Amazon EKS 类型的附加组件
#如果返回来的是一个错误，则表明您的集群上没有安装 Amazon EKS 类型的附加组件
```

# Amazon EKS 类型的附加组件
* 安装Amazon EKS 类型的附加组件
>如果您对当前附加组件应用的自定义设置与 Amazon EKS 附加组件的默认设置相冲突，则创建可能会失败。如果创建失败，您会收到一条可以帮助您解决问题的错误信息。或者，您可以将 --resolve-conflicts OVERWRITE 添加到命令中。这样一来，附加组件会覆盖任何现有的自定义设置。
```
aws eks create-addon --cluster-name my-cluster --addon-name vpc-cni --addon-version v1.13.2-eksbuild.1 \
    --service-account-role-arn arn:aws:iam::111122223333:role/AmazonEKSVPCCNIRole
```
* 更新Amazon EKS 类型的附加组件
```
aws eks update-addon --cluster-name my-cluster --addon-name vpc-cni --addon-version v1.13.2-eksbuild.1 \
    --service-account-role-arn arn:aws:iam::111122223333:role/AmazonEKSVPCCNIRole \
    --resolve-conflicts PRESERVE --configuration-values '{"env":{"AWS_VPC_K8S_CNI_EXTERNALSNAT":"true"}}'
```

# 自我管理的附加组件
* 查看集群上当前安装的容器映像版本
```sh
kubectl describe daemonset aws-node --namespace kube-system | grep amazon-k8s-cni: | cut -d : -f 3
```
* 保存当前安装的附加组件的配置
```
kubectl get daemonset aws-node -n kube-system -o yaml > aws-k8s-cni-old.yaml
```
* 如果有自定义设置，请使用以下命令下载清单文件
```
curl -O https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.13.0/config/master/aws-k8s-cni.yaml
```
* 然后将修改后的清单应用到集群
```
kubectl apply -f aws-k8s-cni.yaml
```

* [恢复默认自我管理附加组件](https://eksctl.io/usage/addon-upgrade/)
>There are 3 default add-ons that get included in each EKS cluster: - kube-proxy - aws-node - coredns; For official EKS addons that are created manually through `eksctl create   addons` or upon cluster creation
```
# 更新addon版本，并将所有配置更改覆盖回EKS的默认值(慎用)
eksctl utils update-kube-proxy --cluster=<clusterName>
eksctl utils update-aws-node --cluster=<clusterName>
eksctl utils update-coredns --cluster=<clusterName>
```