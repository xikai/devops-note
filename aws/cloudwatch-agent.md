* https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html

# 在ec2上安装cloudwatch agent
### [为ec2实例附加IAM角色或AWS策略](https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent-commandline.html)
>要使 CloudWatch 代理能够从实例发送数据，您必须将 IAM 角色附加到实例
* 附加AWS拖管策略
```
CloudWatchAgentServerPolicy
AWSXRayDaemonWriteAccess
```

### 下载安装CloudWatch-agent 软件包
* Amazon Linux 2023 和 Amazon Linux 2 
```
yum install amazon-cloudwatch-agent
```
* 其它操作系统
> 对于每个下载链接，有一个常规链接以及每个区域的链接
```
# 例如，对于 Amazon Linux 2023 和 Amazon Linux 2 以及 x86-64 架构
https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm

https://amazoncloudwatch-agent-us-east-1.s3.us-east-1.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
https://amazoncloudwatch-agent-eu-central-1.s3.eu-central-1.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
```
* 安装软件包
```
rpm -U ./amazon-cloudwatch-agent.rpm
```

### 创建 CloudWatch-agent配置文件
>配置文件是一个 JSON 文件，它指定了该代理要收集的指标、日志和跟踪信息，包括自定义指标
* CloudWatch-agent配置向导创建配置文件
```
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```
### [手动创建或编辑 CloudWatch 代理配置文件](https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html)
* [unix上的 CloudWatch 代理收集的指标](https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/monitoring/metrics-collected-by-CloudWatch-agent.html#linux-metrics-enabled-by-CloudWatch-agent)
* 该配置文件的架构定义文件：/opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json

* [收集网络性能指标](https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-network-performance.html)
```json
# /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 10,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}"
    },
    "metrics_collected": {
      "ethtool": {
        "interface_include": [
           "eth1"
        ],
        "metrics_include": [
          "rx_packets",
          "tx_packets",
          "bw_in_allowance_exceeded",
          "bw_out_allowance_exceeded",
          "conntrack_allowance_exceeded",
          "linklocal_allowance_exceeded",
          "pps_allowance_exceeded"
        ]
      }
    }
  }
}
```

### systemd启动
```sh
# /etc/systemd/system/amazon-cloudwatch-agent.service
# /opt/aws/amazon-cloudwatch-agent/bin/start-amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent
```

# EKS DaemonSet安装 cloudwatch-agent(采集ethtool指标)
* [网络微爆发](https://repost.aws/zh-Hans/knowledge-center/ec2-instance-exceeding-network-limits)
```yml
---
apiVersion: v1
kind: Namespace
metadata:
  name: cloudwatch-ethtool
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cwagentconfig
  namespace: cloudwatch-ethtool
data:
  cwagentconfig.json: |
    {
      "agent": {
        "metrics_collection_interval": 10
      },
      "metrics": {
        "append_dimensions": {
          "InstanceId": "${aws:InstanceId}"
        },
        "metrics_collected": {
          "ethtool": {
            "interface_include": [
               "eth1"
            ],
            "metrics_include": [
              "rx_packets",
              "tx_packets",
              "bw_in_allowance_exceeded",
              "bw_out_allowance_exceeded",
              "conntrack_allowance_exceeded",
              "linklocal_allowance_exceeded",
              "pps_allowance_exceeded"
            ]
          }
        }
      }
    }
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: cloudwatch-agent-ethtool
  namespace: cloudwatch-ethtool
spec:
  selector:
    matchLabels:
      name: cloudwatch-agent-ethtool
  template:
    metadata:
      labels:
        name: cloudwatch-agent-ethtool
    spec:
      #nodeSelector:
      #  kubernetes.io/arch: arm64
      serviceAccountName: cloudwatch-agent-ethtool
      terminationGracePeriodSeconds: 30
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      containers:
      - name: cloudwatch-agent
        image: amazon/cloudwatch-agent:1.300041.0b681
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: 200Mi
            cpu: 200m
        volumeMounts:
          - name: cwagentconfig
            mountPath: /etc/cwagentconfig
      volumes:
        - name: cwagentconfig
          configMap:
            name: cwagentconfig
```
```sh
#!/bin/bash
# usage: bash -x install.sh

AWS_ACCOUNT_ID=123456789012
AWS_COUNTRY=aws
REGION=us-west-2
CLUSTER_NAME=newproduct

# 为集群创建 IAM OIDC 提供商
### 检索集群的 OIDC 提供商 ID 并将其存储在变量中
oidc_id=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
is_associate=$(aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4)
if [ -z $is_associate ] ;then
    eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --approve
else
    echo "iam oidc provider has been associated."
fi

# 创建 IAM 角色和 Kubernetes 服务账户,并向其附加此 IAM policy
eksctl create iamserviceaccount \
  --name=cloudwatch-agent-ethtool \
  --cluster=$CLUSTER_NAME \
  --namespace=cloudwatch-ethtool \
  --role-name CloudWatchAgentServerRole_ethtool_$CLUSTER_NAME \
  --attach-policy-arn arn:$AWS_COUNTRY:iam::aws:policy/CloudWatchAgentServerPolicy \
  --approve

# 部署cloudwatch-agent daemontset
kubectl apply -f cloudwatch-agent-ethtool.yaml
```

# [使用 Amazon CloudWatch Observability EKS 附加组件安装 CloudWatch Agent](https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html)
>让 CloudWatch 代理能够向 CloudWatch 发送指标、日志和跟踪；授予 IAM 权限
### EKS控制台安装amazon-cloudwatch-observability插件
* 配置值（不收集容器日志）
```
{ "containerLogs": { "enabled": false } }
```

### eksctl安装amazon-cloudwatch-observability插件
*  使用 IAM 服务账户角色进行安装
```sh
#  OpenID Connect（OIDC）提供程序
eksctl utils associate-iam-oidc-provider --cluster my-cluster-name --approve

# 创建附加了 CloudWatchAgentServerPolicy 策略的 IAM 角色，然后使用 OIDC 将代理服务账户配置为代入该角色
eksctl create iamserviceaccount \
  --name cloudwatch-agent \
  --cluster my-cluster-name \
  --namespace amazon-cloudwatch \
  --role-name cloudwathch-agent-role \      #cloudwathch-agent-role为要将sa关联到的角色名称
  --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --role-only \
  --approve
```
```sh
aws eks create-addon \
  --addon-name amazon-cloudwatch-observability \
  --cluster-name my-cluster-name \
  --service-account-role-arn arn:aws:iam::111122223333:role/my-service-account-role \ 
  --configuration-values '{
    "agent": {
      "config": {
        "logs": {
          "metrics_collected": {
            "app_signals": {},
            "kubernetes": {
              "enhanced_container_insights": true,
              "accelerated_compute_metrics": false   #不从 EKS 工作负载收集 NVIDIA GPU 指标
            }
          }
        },
        "traces": {
          "traces_collected": {
            "app_signals": {}
          }
        },
        "containerLogs": {
          "enabled": false  #不收集容器日志
        }
      }
    }
  }'
```
```yml
{
  "containerLogs": {
    "enabled": false
  },
  "agent": {
    "config": {
      "agent": {
        "region": "us-east-1"
      },
      "logs": {
        "metrics_collected": {
          "application_signals": {},
          "kubernetes": {
            "enhanced_container_insights": true
          }
        }
      },
      "traces": {
        "traces_collected": {
          "application_signals": {}
        }
      },
      "metrics": {
        "append_dimensions": {
          "InstanceId": "${aws:InstanceId}"
        },
        "metrics_collected": {
          "ethtool": {
            "interface_include": ["*"], 
            "metrics_include": [
              "rx_packets",
              "tx_packets",
              "bw_in_allowance_exceeded",
              "bw_out_allowance_exceeded",
              "conntrack_allowance_exceeded",
              "conntrack_allowance_available",
              "linklocal_allowance_exceeded",
              "pps_allowance_exceeded"
            ]
          }
        }
      }
    }
  }
}
```



