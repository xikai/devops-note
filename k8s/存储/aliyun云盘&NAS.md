* 自建k8s需要安装阿里云 Kubernetes 存储插件,如果使用flexVolume需要安装flexVolume
* 云盘为非共享存储，只能同时被一个 pod 挂载。
*  集群中只有与云盘在同一个可用区（Zone）的节点才可以挂载云盘(待挂载的云盘类型必须是按量付费)
* K8S集群会默认部署Provisioner，Provisioner创建云盘需要对云盘有操作权限，可以通过AK、或STS token来获取权限；
```
配置AK：在部署Provisioner的时候设置ACCESS_KEY_ID、ACCESS_KEY_SECRET环境变量，可以配置ak；
配置STS：为默认方式，可以给集群（Master节点）授予RAM权限（创建RAM服务角色，并添加管理ECS权限）；
```

### 安装阿里云flexVolume插件和Disk Provisioner
* https://help.aliyun.com/document_detail/86785.html?spm=a2c4g.11186623.6.676.141f788dPBxo8W
```
1. 需要修改image
```
>动态挂载方式是指在应用中显式声明PVC，并在PVC中声明StorageClass；这时应用会通过Storageclass中指定的Provisioner来自动创建云盘，并自动生成云盘PV资源类型；

### 创建云盘动态存储卷
> https://help.aliyun.com/document_detail/86612.html?spm=a2c4g.11186623.6.677.c648788d5cJosz#h2-url-2

### 创建阿里云NAS动态存储卷
* 创建ServiceAccount
> vi admin-role.yaml
```yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system
```
```
kubectl apply -f admin-role.yaml
# 或用命令创建
# kubectl create serviceaccount --namespace kube-system admin
# kubectl create clusterrolebinding admin --clusterrole=cluster-admin --serviceaccount=kube-system:admin
```

* 创建阿里云NAS存储控制器
> https://help.aliyun.com/document_detail/88940.html?spm=a2c4g.11186623.6.678.c648788d5cJosz#h2-url-3
```
1.修改image
2.修改nfs server
```