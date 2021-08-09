* Helm Operator watch所有安装HelmRelease资源

### 安装 Helm Operator
* 安装HelmRelease CRD(用于定义HelmRelease资源)
```
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/1.4.0/deploy/crds.yaml
```

* 创建credentials
```
kubectl create secret generic flux-git-deploy \
    --from-file=identity=<path to key file>
```

* 安装 helm-operator
```
kubectl create ns flux
helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i helm-operator fluxcd/helm-operator \
    --namespace flux \
    --set git.ssh.secretName=flux-git-deploy

$ kubectl get pods -n flux
NAME                             READY   STATUS    RESTARTS   AGE
helm-operator-6985656995-dpmdl   1/1     Running   0          31s
```

### 部署chart
* 创建一个HelmRelease资源
```
cat <<EOF | kubectl apply -f -
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: ghost
  namespace: default
spec:
  chart:
    git: git@github.com:xikai-dd01/flux-get-started
    ref: master
    path: charts/ghost
  helmVersion: v3
  releaseName: ghost
  values:
    replicaCount: 1
EOF
```

* 查看HelmRelease资源
```
$ kubectl get helmrelease (hr)
NAME      RELEASE           STATUS     MESSAGE                       AGE
ghost   default-ghost   deployed   Helm release sync succeeded   59s

$ kubectl describe helmrelease ghost
```
```
$ kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
default-ghost-7f9759cc66-bslsl   1/1     Running   0          59s
```

* 修改HelmRelease资源,增加ghost副本的数量
>kubectl edit helmrelease/ghost
```
...
spec:
  chart:
    git: git@github.com:xikai-dd01/flux-get-started
    ref: master
    path: charts/ghost
  helmVersion: v3
  releaseName: ghost
  values:
    replicaCount: 2
```

### 卸载chart
```
kubectl delete helmrelease podinfo
```