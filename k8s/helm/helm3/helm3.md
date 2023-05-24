* [helm可支持kubernetes的版本偏差](https://helm.sh/zh/docs/topics/version_skew/)

# [安装helm3](https://helm.sh/zh/docs/intro/install/)
* 二进制安装
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
* dockerfile安装
```
FROM alpine/helm:latest as helm3
FROM python:3.8-slim-buster AS python
COPY --from=helm3 /usr/bin/helm /usr/local/bin/helm
```
* help
```
helm --help
```


# helm repo
```sh
# 查看chart仓库
helm repo list
# 添加chart repo
helm repo add bitnami https://charts.bitnami.com/bitnami
# 从你所添加的仓库中查找chart
helm search repo bitnami
# 从 Artifact Hub(https://artifacthub.io/) 中查找并列出 helm charts
helm search hub wordpress
```

# helm install 
```
# helm install [release_name] [chart_name]
helm install happy-panda bitnami/wordpress
```
* --values (或 -f)：使用 YAML 文件覆盖配置。可以指定多次，优先使用最右边的文件
```
helm install -f values.yaml happy-panda bitnami/wordpress
```
* --set：通过命令行的方式对指定项进行覆盖
>如果同时使用两种方式，则 --set 中的值会被合并到 --values 中，但是 --set 中的值优先级更高
```
helm install happy-panda bitnami/wordpress \
--set name1=val1,name2=val2
--set outer.inner=value 当Key有层级关系时
--set name={a, b, c} 当Value为数组时
--set servers[0].port=80 当要给定数组中第1个元素的某个Key赋值时
--set servers[0].port=80,servers[0].host=example 当同时要给数组中第1个元素的多个key赋值时
--set name=value1\,value2 Value中含有特殊字符时，使用转义字符
--set nodeSelector."kubernetes\.io/role"=master，Key中含有特殊字符时，使用双引号
```
```
helm get values <release-name> 来查看指定 release 中 --set 设置的值(用户提供的values)
```
* 更多安装方法
  - chart 的仓库（如上所述）
  - 本地 chart 压缩包
      ```
      helm install foo foo-0.1.1.tgz
      ```
  - 解压后的 chart 目录
      ```
      helm install foo path/to/foo
      ```
  - 完整的 URL
      ```
      helm install foo https://example.com/charts/foo-1.2.3.tgz
      ```

# helm status 
```
# 追踪 release 的状态 或是重新读取配置信息
helm status happy-panda
```

# helm show values 查看 chart 中的可配置选项
```
helm show values bitnami/wordpress
```

# helm upgrade 升级 release
>它只会更新自上次发布以来发生了更改的内容
```sh
helm upgrade -f panda.yaml happy-panda bitnami/wordpress

# Helm查看是否已经安装版本， 如果没有，会执行安装；如果版本存在，会进行升级
helm upgrade --install <release name> --values <values file> <chart directory>
```

# helm rollback 回滚到之前的发布版本
```sh
# helm rollback [RELEASE] [REVISION]
helm rollback happy-panda 1
```
* 查看一个特定 release 的修订版本号
```
helm history [RELEASE] 
```

# helm uninstall 卸载 release
```sh
helm uninstall happy-panda
# 在 Helm 3 中，删除也会移除 release 的记录， 如果你想保留删除记录
helm uninstall --keep-history
```

# helm list 查看当前部署的所有 release
```sh
# 展示己部署的release
helm list
# 展示 Helm 保留的所有 release 记录，包括失败或删除的条目（指定了 --keep-history）
helm list --all
# 只展示使用了 --keep-history 删除的 release
helm list --uninstalled
```

# 创建你自己的 charts
```sh
helm create deis-workflow

# 现在，./deis-workflow 目录下已经有一个 chart 了。你可以编辑它并创建你自己的模版
```
* 验证格式是否正确
```
helm lint 
```
* 当准备将 chart 打包分发时
```sh
helm package deis-workflow
# deis-workflow-0.1.0.tgz
```
```
helm install deis-workflow ./deis-workflow-0.1.0.tgz
```

# [创建一个chart仓库](https://helm.sh/zh/docs/topics/chart_repository/)