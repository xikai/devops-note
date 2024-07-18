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
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent
```


# [使用 Amazon CloudWatch Observability EKS 附加组件安装 CloudWatch Agent](https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html)
>让 CloudWatch 代理能够向 CloudWatch 发送指标、日志和跟踪；授予 IAM 权限(两种方式)
* 选项 1：将 CloudWatchAgentServerPolicy IAM 策略附加到您的 Worker 节点上
```
aws iam attach-role-policy \
--role-name my-worker-node-role \  # my-worker-node-role 为 Kubernetes Worker 节点使用的 IAM 角色
--policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
```
```
aws eks create-addon --addon-name amazon-cloudwatch-observability --cluster-name my-cluster-name
```

* 选项 2： 使用 IAM 服务账户角色进行安装
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

