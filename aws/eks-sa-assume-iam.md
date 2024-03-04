* https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/associate-service-account-role.html
* https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/pod-configuration.html

# 配置 Kubernetes 服务账户以代入 IAM 角色
* 创建一个包含 Pods 访问 AWS 服务 所需权限的文件
```yml
# 示例策略文件，以实现pod容器 对 Amazon S3 存储桶的只读访问权限
cat >my-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::my-pod-secrets-bucket"
        }
    ]
}
EOF
```
* 创建 IAM policy
```
aws iam create-policy --policy-name my-policy --policy-document file://my-policy.json
```

* 创建 IAM 角色并将其与 Kubernetes 服务账户关联
```
eksctl create iamserviceaccount \
--cluster my-cluster \
--namespace default \
--name my-service-account \
--role-name my-role \
--attach-policy-arn arn:aws:iam::111122223333:policy/my-policy \
--approve
```

* 确认角色和服务账户配置正确
```
# 确认 IAM 角色的信任策略配置正确
aws iam get-role --role-name my-role --query Role.AssumeRolePolicyDocument

# 确认您在上一步中附加到角色的策略已附加到该角色
aws iam list-attached-role-policies --role-name my-role --query AttachedPolicies[].PolicyArn --output text

# 确认使用角色注释 Kubernetes 服务账户
kubectl describe serviceaccount my-service-account -n default
```

# 配置 Pods 以使用 关联了IAM角色的 Kubernetes 服务账户
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      serviceAccountName: my-service-account
      containers:
      - name: my-app
        image: public.ecr.aws/nginx/nginx:X.XX
```

* 查看 Pod 使用的 IAM 角色的 ARN
```
kubectl describe pod my-app-6f4dfff6cb-76cv9 | grep AWS_ROLE_ARN:

#示例输出如下
AWS_ROLE_ARN:                 arn:aws:iam::111122223333:role/my-role
```