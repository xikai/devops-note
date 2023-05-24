* https://eksctl.io/usage/vpc-networking/

# 创建专有VPC创建eks集群
>默认将创建一个专有VPC，VPC CIDR为192.168.0.0/16。它被分为8(/19)个子网(3个私有子网，3个公共子网和2个预留子网.In us-east-1 eksctl only creates 2 public and 2 private subnets by default)。初始节点组创建在公共子网中。禁用SSH访问，除非指定--allow-ssh
```
eksctl create cluster --allow-ssh=test
```

# 创建自定义vpc创建eks集群
* Change VPC CIDR
```
eksctl create cluster --vpc-cidr=10.10.0.0/16 --allow-ssh=test
```
* cluster.yaml自定义配置文件创建eks集群
```yml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: cluster-2
  region: eu-north-1

vpc:
  cidr: 10.10.0.0/16
  autoAllocateIPv6: true
  # disable public access to endpoint and only allow private access
  clusterEndpoints:
    publicAccess: false
    privateAccess: true

nodeGroups: []
```
```
eksctl create cluster -f cluster.yaml
```

# 使用己存在的VPC创建eks集群
  1. 必须提供2个子网在不同可用区
  2. 子网至少有以下标记
    ```
    kubernetes.io/cluster/<name> tag set to either shared or owned
    kubernetes.io/role/internal-elb tag set to 1 for private subnets
    kubernetes.io/role/elb tag set to 1 for public subnets
    ```

* Examples
```
eksctl create cluster \
  --vpc-private-subnets=subnet-0ff156e0c4a6d300c,subnet-0426fb4a607393184 \
  --vpc-public-subnets=subnet-0153e560b3129a696,subnet-009fa0199ec203c37
```
* 或使用配置文件创建
```yml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: my-test
  region: us-west-2

vpc:
  id: "vpc-11111"
  subnets:
    private:
      us-west-2a:
          id: "subnet-0ff156e0c4a6d300c"
      us-west-2c:
          id: "subnet-0426fb4a607393184"
    public:
      us-west-2a:
          id: "subnet-0153e560b3129a696"
      us-west-2c:
          id: "subnet-009fa0199ec203c37"

nodeGroups:
  - name: ng-1

```

* 使用3个私有子网的自定义VPC创建eks集群（初始节点组使用这些私有子网）
```
eksctl create cluster \
  --vpc-private-subnets=subnet-0ff156e0c4a6d300c,subnet-0549cdab573695c03,subnet-0426fb4a607393184 \
  --node-private-networking
```
```yml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: my-test
  region: us-west-2

vpc:
  id: "vpc-11111"
  subnets:
    private:
      us-west-2d:
          id: "subnet-0ff156e0c4a6d300c"
      us-west-2c:
          id: "subnet-0549cdab573695c03"
      us-west-2a:
          id: "subnet-0426fb4a607393184"

nodeGroups:
  - name: ng-1
    privateNetworking: true   #如果节点组要创建到私有子网，必须开启
```
