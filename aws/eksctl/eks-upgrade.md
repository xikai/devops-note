# 一、升级EKS托管附加组件(通过EKS插件控制台)
## [vpc-cni](https://docs.amazonaws.cn/eks/latest/userguide/managing-vpc-cni.html)
* 查询指定k8s版本对应的插件默认版本
```
aws eks describe-addon-versions --kubernetes-version 1.28 --addon-name vpc-cni  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table
```
* 自定义CNI配置：EKS控制台 --> 插件 --> vpc-cni --> 可选配置设置 添加以下自义定变量，冲突解决方法选择: 覆盖
>保留(自定义配置覆盖eks默认配置)，覆盖(eks默认配置覆盖自定义配置)，无(等于覆盖)
```
{"env": {"AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG": "true",
    "AWS_VPC_K8S_CNI_EXTERNALSNAT": "true",
    "ENABLE_PREFIX_DELEGATION": "true",
    "WARM_PREFIX_TARGET": "1",
    "ENI_CONFIG_LABEL_DEF":"failure-domain.beta.kubernetes.io/zone"
}}
```
## [coredns](https://docs.amazonaws.cn/eks/latest/userguide/managing-coredns.html)
* 查询指定k8s版本对应的插件默认版本
```
aws eks describe-addon-versions --kubernetes-version 1.28 --addon-name coredns  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table
```

# 二、更新控制面板
```
eksctl version
eksctl upgrade cluster --name my-cluster --version 1.28 --approve
```

# 三、更新节点组
1. 新建节点组（停止项目发布）
2. 老节点组添加污点设置为不可调度(NoSchedule)，并检查确保没有业务pod被调度到新节点组
3. 重启deployment让pod重新调度到新节点组(滚动更新)
    * 循环滚动更新deployment
    ```
    for i in `kubectl get deploy -n front |awk '{if(NR>1){print $1}}'`
    do
        kubectl rollout restart deploy/$i -n front
        sleep 2
    done
    ```
    * 查询指定节点组下运行的pod
    ```
    kubectl get nodes -l "alpha.eksctl.io/nodegroup-name=front-ng-c" |awk '{if(NR>1) {print $1}}'| while read NODE
    do
        kubectl get pod -A -owide |grep $NODE
    done
    ```
    * 按创建时间排序查询pod,检查遗漏未重启的pod应用
    ```
    k get pods -A --sort-by='.metadata.creationTimestamp' -o wide
    ```
## 4. [升级kube-proxy](https://docs.amazonaws.cn/eks/latest/userguide/managing-kube-proxy.html)
* 查询指定k8s版本对应的插件默认版本
```
aws eks describe-addon-versions --kubernetes-version 1.28 --addon-name kube-proxy  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table
```

# 四、[Cluster Autoscaler](https://docs.amazonaws.cn/eks/latest/userguide/autoscaling.html)
* 将 Cluster Autoscaler 更新为与您升级后的 Kubernetes 主版本和次要版本匹配的最新版本
```
# https://github.com/kubernetes/autoscaler/releases/tag/cluster-autoscaler-1.25.3
kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=registry.k8s.io/autoscaling/cluster-autoscaler:v1.25.3
```


# 更新自行管理的附加组件（升级为当前eks版本支持的最新版本）
>建议您向集群添加 Amazon EKS 类型的附加组件，而不是自行管理类型的附加组件。
## [vpc-cni](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/managing-vpc-cni.html#vpc-add-on-self-managed-update)
* 确认已在集群上安装自行管理类型的附加组件(如果返回错误消息，则表明集群上安装有自行管理类型的附加组件)
```
aws eks describe-addon --cluster-name my-cluster --addon-name vpc-cni --query addon.addonVersion --output text
```
* 查看集群上当前安装的容器镜像版本
```
kubectl describe daemonset aws-node --namespace kube-system | grep amazon-k8s-cni: | cut -d : -f 3
    v1.12.6-eksbuild.2 #输出可能不包含版本号
```
* 备份当前vpc-cni配置，以便在更新版本后可以配置相同设置
```
kubectl get daemonset aws-node -n kube-system -o yaml > aws-k8s-cni-old.yaml
```
* 建议更新到[最新可用版本表](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/managing-vpc-cni.html#vpc-cni-latest-available-version)中列出的相同 major.minor.patch 版本
```
# 如果您的附加组件没有任何自定义设置,请在 GitHub 上针对要更新到的版本运行 To apply this release
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.15.1/config/master/aws-k8s-cni.yaml
```
```
# 如果有自定义设置，请使用以下命令下载清单文件,使用自定义设置修改清单，然后将修改后的清单应用到集群
curl -O https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.15.1/config/master/aws-k8s-cni.yaml
kubectl apply -f aws-k8s-cni.yaml
```

## [coredns](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/managing-coredns.html#coredns-add-on-self-managed-update)
* 确认已在集群上安装自行管理类型的附加组件(如果返回错误消息，则表明集群上安装有自行管理类型的附加组件)
```
aws eks describe-addon --cluster-name my-cluster --addon-name coredns --query addon.addonVersion --output text
```
* 查看集群上当前安装的容器镜像版本
```
kubectl describe deployment coredns -n kube-system | grep Image
    Image:       961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn/eks/coredns:v1.8.7-eksbuild.3
```
* 如果您要更新到 CoreDNS 1.8.3 或更高版本
```
kubectl edit clusterrole system:coredns -n kube-system
# 在文件中的 rules 部分的现有权限行下添加以下行
[...]
- apiGroups:
  - discovery.k8s.io
  resources:
  - endpointslices
  verbs:
  - list
  - watch
[...]
```
* 更新镜像
```
# 将 account-id 和 region-code 替换为上一步中返回的输出值来更新 CoreDNS 附件组件。将 镜像版本 替换为您的 Kubernetes 版本的最新版本表中列出的 CoreDNS 版本
kubectl set image deployment.apps/coredns -n kube-system  coredns=961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn/eks/coredns:v1.9.3-eksbuild.7
```

## [kube-proxy](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/managing-kube-proxy.html)
>kube-proxy次要版本不能高于node节点组的次要版本,先升级节点组
* 确认已在集群上安装自行管理类型的附加组件(如果返回错误消息，则表明集群上安装有自行管理类型的附加组件)
```
aws eks describe-addon --cluster-name my-cluster --addon-name kube-proxy --query addon.addonVersion --output text
```
* 查看集群上当前安装的容器镜像版本
```
kubectl describe daemonset kube-proxy -n kube-system | grep Image
    Image:      961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn/eks/kube-proxy:v1.24.7-minimal-eksbuild.2
```
* 更新镜像
```
# 将 account-id 和 region-code 替换为上一步中返回的输出值来更新 CoreDNS 附件组件。将 镜像版本 替换为您的 Kubernetes 版本的最新版本表中列出的 CoreDNS 版本
kubectl set image daemonset.apps/kube-proxy -n kube-system kube-proxy=961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn/eks/kube-proxy:v1.25.14-minimal-eksbuild.2
```
* 再次检查容器映像版本
```
kubectl describe deployment coredns -n kube-system | grep Image | cut -d ":" -f 3
```


## TroubleShooting

1. 当`vpc-cni`版本不一致情况下
   1. 升级页面上的版本时，只能一次跨一个小版本升级
   2. 升级插件期间，不允许都新的`pod`生成
   3. 如果自托管安装的插件和`eks`发生冲突时， 推荐在页面控制台将行为选择为 保留（有个BUG, `VPC CNI中 AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG`未被保留）， 
      1. 解决方式: 在修改自定义的vpc cni插件时
         1. 不能直接`edit daemonset`
         2. 建议使用set env (当set env多次时会重启多次)或者 页面上写上配置值（格式选择json），行为选择**覆盖**，**推荐使用页面编辑这种方式减少影响**
2. 在更新节点组的版本时，出现`Reached max retries while trying to evict pods from nodes in node group ng-test-backend2`
   1. 原因: `pdb`有些服务设置了`minAvaiable`为1 并且在升级节点组时选择了滚动更新 （`kubectl get pdb -A`）
   2. 解决: 升级节点组时，选择**强制更新** 或 在选择滚动更新的前提下，编辑那些设置了`minAvaiable`为1的应用的`pdb`，编辑`minAvaiable: 1`为`maxUnavaiable: 1`，并重新升级该节点组