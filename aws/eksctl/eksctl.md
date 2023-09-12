* https://eksctl.io/

# 先决条件
1. 创建VPC，2个子网在不同可用区
2. 安装kubectl、eksctl、awscli
3. 所需的 IAM 权限(您正在使用的 IAM 安全主体必须具有使用 Amazon EKS IAM 角色、服务相关角色、AWS CloudFormation、VPC 和相关资源的权限)
```
# 您必须以同一用户身份完成本指南中的所有步骤。要查看当前用户，请运行以下命令
aws sts get-caller-identity
```

# 创建eks集群
```
eksctl create cluster --name my-cluster --region region-code
```

# 删除eks集群
```
eksctl delete cluster --name my-cluster --region region-code
```

# [管理 Amazon EKS 附加组件](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/managing-add-ons.html)
* 获取addons for eksctl
```
eksctl get addon --cluster my-cluster
```
* 安装addon
```
# 查询k8s1.27版本可用的addon插件版本
eksctl utils describe-addon-versions --kubernetes-version 1.27 | grep AddonName
eksctl utils describe-addon-versions --kubernetes-version 1.27 --name vpc-cni | grep AddonVersion
# 安装指定版本插件
eksctl create addon --cluster my-cluster --name name-of-addon --version latest \
    --service-account-role-arn arn:aws:iam::111122223333:role/role-name --force
```
* 更新addon
```yml
cat >update-addon.yaml <<EOF
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: my-cluster
  region: region

addons:
- name: vpc-cni
  version: latest
  serviceAccountRoleARN: arn:aws:iam::111122223333:role/role-name
  resolveConflicts: preserve   # preserve 选项保留附加组件的现有值, overwrite 则所有设置都将更改为 Amazon EKS 的默认值
EOF
```
```
eksctl update addon -f update-addon.yaml
```

* 删除addon
```
# 如果您删除了 --preserve 选项，则除了 Amazon EKS 不再管理附加组件外，附加软件也会从集群中删除
eksctl delete addon --cluster my-cluster --name name-of-addon --preserve
```

# 更新默认addon更新
>There are 3 default add-ons that get included in each EKS cluster: - kube-proxy - aws-node - coredns; For official EKS addons that are created manually through `eksctl create   addons` or upon cluster creation
* 更新addon版本，并将所有配置更改覆盖回EKS的默认值
```
# 慎用,会导致插件之前的自定义配置被还原
eksctl utils update-kube-proxy --cluster=<clusterName>
eksctl utils update-aws-node --cluster=<clusterName>
eksctl utils update-coredns --cluster=<clusterName>
```
