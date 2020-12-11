### 创建k8s集群用户
>https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
* 创建admin role
```
kubectl create namespace kubernetes-dashboard
```

>vim admin-role.yaml

>默认集群角色：https://v1-17.docs.kubernetes.io/zh/docs/reference/access-authn-authz/rbac/#%E9%9D%A2%E5%90%91%E7%94%A8%E6%88%B7%E7%9A%84%E8%A7%92%E8%89%B2
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
  
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev-user
  namespace: kube-test
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding   ###如果使用RoleBinding，只授权控制 RoleBinding 所在命名空间中的所有资源。
metadata:
  name: dev-user
  namespace: kube-test
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit       ###admin不允许对资源配额或者命名空间本身进行写操作,edit不允许查看或者修改角色（Roles）或者角色绑定（RoleBindings）,view允许对命名空间的大多数对象有只读权限。它不允许查看角色（Roles）或角色绑定（RoleBindings），它不允许查看 Secrets。
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: kube-test
```
```
kubectl apply -f admin-role.yaml
```

* 查看用户token (用于访问集群)
```
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
kubectl -n kube-prod describe secret $(kubectl -n kube-prod get secret | grep dev-user | awk '{print $1}')
```

### 部署k8s dashboard
* 为 dashboard 签发证书及密钥
```
mkdir certs
openssl req -nodes -newkey rsa:2048 -keyout certs/dashboard.key -out certs/dashboard.csr -subj "/C=/ST=/L=/O=/OU=/CN=kubernetes-dashboard"
## 利用 key 和私钥生成证书
openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt
```
```
kubectl create ns kubernetes-dashboard
kubectl create secret generic kubernetes-dashboard-certs --from-file=./certs -n kubernetes-dashboard
```

* 下载官方dashboard yaml部署文件
>https://github.com/kubernetes/dashboard
```
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

kubectl apply -f recommended.yaml
```

### 访问k8s dashborad
* kubectl proxy启动本地代理访问
```
# kubectl proxy
starting to server on 127.0.0.1:8001
```
```
#访问（使用token令牌）
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

* 通过master API地址访问（需要用kubeconfig生成证书导入浏览器）
```
https://<master-ip>:<apiserver-port>/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```
```
grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.crt
grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.key
openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-client"  #必须输入密码（后续导入证书需要）

#双击kubecfg.p12证书导入，重启浏览器访问
```

* NodePort
>vim recommended.yaml 修改service
```
# ------------------- Dashboard Service ------------------- #

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30001    # 添加nodeport固定IP
  type: NodePort         # service类型为NodePort
  selector:
    k8s-app: kubernetes-dashboard
```