* flux 监视&同步git仓库的k8s yaml清单
* https://fluxcd.io/legacy/flux/tutorials/get-started/
* https://fluxcd.io/legacy/flux/references/fluxctl/

### 安装fluxctl
```
curl -s -L https://github.com/fluxcd/flux/releases/download/1.23.2/fluxctl_linux_amd64 -o /usr/local/bin/fluxctl
chmod +x /usr/local/bin/fluxctl
```
* fork示例github repo (https://github.com/fluxcd/flux-get-started)

### fluxctl install flux
```
kubectl create ns flux

fluxctl install \
--git-user=xikai-dd01 \
--git-email=xikai-dd01@users.noreply.github.com \
--git-url=git@github.com:xikai-dd01/flux-get-started \
--git-path=namespaces,workloads \   #指定k8s清单目录（相对路径）
--namespace=flux | kubectl apply -f -

# 等待flux启动
kubectl rollout status deployment/flux -n flux 
```

* 授权读写github仓库
```
# Flux 生成一个 SSH 密钥并记录公钥
fluxctl identity --k8s-fwd-ns flux

# 为了将您的集群状态与 git 同步，您需要复制生成的公钥并在您的 GitHub 存储库上创建一个具有写访问权限的部署密钥
# 打开 GitHub，导航到xikai-dd01/flux-get-started，转到Setting > Deploy keys，单击Add deploy key，给它一个Title，选中Allow write access，粘贴 Flux 公钥并单击Add key
```

* 同步github（默认情况下，Flux git pull 频率设置为 5 分钟。您可以告诉 Flux 立即同步更改）
```
fluxctl sync --k8s-fwd-ns flux
```

### 验证安装
```
 05:28 $ kubectl get pod -n demo
NAME                       READY   STATUS    RESTARTS   AGE
podinfo-666f7547cc-7xbd5   1/1     Running   0          53s
podinfo-666f7547cc-jqzrh   1/1     Running   0          68s
```
* 查看 Flux 日志
```
kubectl -n flux logs deployment/flux -f
```

### 操作flux
* 查看flux workloads
```
$ fluxctl list-workloads --k8s-fwd-ns=flux

# 列出workloads镜像版本
$ luxctl list-images --k8s-fwd-ns=flux --workload default:deployment/helloworld
WORKLOAD                       CONTAINER   IMAGE                          CREATED
default:deployment/helloworld  helloworld  quay.io/weaveworks/helloworld
                                           '-> master-9a16ff945b9e        20 Jul 16 13:19 UTC
                                               master-b31c617a0fe3        20 Jul 16 13:19 UTC
                                               master-a000002             12 Jul 16 17:17 UTC
                                               master-a000001             12 Jul 16 17:16 UTC
                               sidecar     quay.io/weaveworks/sidecar
                                           '-> master-a000002             23 Aug 16 10:05 UTC
                                               master-a000001             23 Aug 16 09:53 UTC

```
* 连接指定flux daemon
```
fluxctl --url http://127.0.0.1:3030/api/flux list-workloads
```

* 发布更新workloads
```
fluxctl release --k8s-fwd-ns=flux  --workload=default:deployment/helloworld
```

* 自动化部署（当检测到新的image、tag时会自动进行部署）
```
fluxctl automate --workload=default:deployment/helloworld
```

* Locking workloads(禁止手动或自动化部署，文件改变继续同步)
```
fluxctl lock --workload=deployment/helloworld
```
* Unlocking Workload(开启手动或自动化部署)
```
fluxctl unlock --workload=deployment/helloworld
```

* 当自动化打开时，针对“prod”分支构建的标签部署
```
fluxctl policy --workload=default:deployment/helloworld --tag-all='prod-*'
```

* 回滚workloads
```
# 取消自动化
fluxctl deautomate --k8s-fwd-ns=flux --workload=default:deployment/helloworld
# 回滚
fluxctl release --workload=default:deployment/helloworld --update-image=quay.io/weaveworks/helloworld:master-a000001
```


### helm install flux(可多次安装)
```
ssh-keygen -q -N "" -f /tmp/identity
kubectl -n flux create secret generic flux-ssh --from-file=/tmp/identity

kubectl create ns flux
helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i flux fluxcd/flux \
   --namespace flux \
   --set git.url=git@github.com:xikai-dd01/flux-get-started \
   --set git.path=workloads \
   --set git.secretName=flux-ssh
   #--set git.secretName=flux-git-deploy
```
