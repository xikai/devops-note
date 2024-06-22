* https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler

# [Cluster Autoscaler on AWS](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md)
## 1. 创建iam策略文件
>Full Cluster Autoscaler Features Policy for AWS (Recommended)
```json
cat >iam_policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
```

## 2. 创建iam角色和k8s服务账户
```bash
#!/bin/bash
# usage: bash -x install.sh

AWS_ACCOUNT_ID=475810397983
AWS_COUNTRY=aws-cn
REGION=cn-northwest-1

CLUSTER_NAME=newdev
POLICY_NAME=AWSEKSClusterAutoscalerIAMPolicy_$CLUSTER_NAME
ROLE_NAME=AmazonEKSClusterAutoscalerRole_$CLUSTER_NAME

# 为集群创建 IAM OIDC 提供商
### 检索集群的 OIDC 提供商 ID 并将其存储在变量中
oidc_id=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
is_associate=$(aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4)
if [ -z $is_associate ] ;then
    eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --approve
else
    echo "iam oidc provider has been associated."
fi

# 创建策略
aws iam create-policy \
    --policy-name $POLICY_NAME \
    --policy-document file://iam_policy.json

# 创建 IAM 角色和 Kubernetes 服务账户,并向其附加此 IAM policy
eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --role-name $ROLE_NAME \
  --attach-policy-arn=arn:$AWS_COUNTRY:iam::$AWS_ACCOUNT_ID:policy/$POLICY_NAME \
  --approve
```

## 3. [下载k8s集群对应版本的cluster-autoscaler.yaml](https://github.com/kubernetes/autoscaler/blob/cluster-autoscaler-release-1.28/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml)
```
wget https://raw.githubusercontent.com/kubernetes/autoscaler/cluster-autoscaler-release-1.28/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

* 删除最上面的ServiceAccount，因为我们在前面已经创建了
```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
  name: cluster-autoscaler
  namespace: kube-system
```

* 修改cluster-autoscaler-autodiscover.yaml的Deployment
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    app: cluster-autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '8085'
    spec:
      priorityClassName: system-cluster-critical
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        fsGroup: 65534
        seccompProfile:
          type: RuntimeDefault
      serviceAccountName: cluster-autoscaler
      containers:
        - image: registry.k8s.io/autoscaling/cluster-autoscaler:v1.28.2   #设置为当前k8s对应的版本
          name: cluster-autoscaler
          resources:
            limits:
              cpu: 100m
              memory: 600Mi
            requests:
              cpu: 100m
              memory: 600Mi
          command:
            - ./cluster-autoscaler
            - --v=4
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=false
            - --expander=least-waste
            - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<YOUR CLUSTER NAME>  #设置<YOUR CLUSTER NAME>为你自己的集群名
```

* 部署cluster-autoscaler
```sh
kubectl apply -f cluster-autoscaler-autodiscover.yaml
```

* Snippet of the cluster-autoscaler pod logs while scaling:
```
I1025 13:48:42.975037       1 scale_up.go:529] Final scale-up plan: [{eksctl-xxx-xxx-xxx-nodegroup-ng-xxxxx-NodeGroup-xxxxxxxxxx 2->3 (max: 8)}]
```