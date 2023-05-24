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