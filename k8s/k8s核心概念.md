# k8s核心概念

## 1. service

`Service`是一种抽象的对象，它定义了一组`Pod`的逻辑集合和一个用于访问它们的策略

一个`Serivce`下面包含的`Pod`集合一般是由`Label Selector`来决定的。



`Node IP`是`Kubernetes`集群中节点的物理网卡`IP`地址(一般为内网)



`Pod IP`是每个`Pod`的`IP`地址，它是`Docker Engine`根据`docker0`网桥的`IP`地址段进行分配的

`	flannel`这种网络插件保证所有节点的`Pod IP`不会冲突



`Cluster IP`是一个虚拟的`IP`，仅仅作用于`Kubernetes Service`这个对象

无法`ping`这个地址，他没有一个真正的实体对象来响应，他只能结合`Service Port`来组成一个可以通信的服务。



在`Kubernetes`集群中，每个`Node`会运行一个`kube-proxy`进程, 负责为`Service`实现一种 VIP（clusterIP）的代理形式

`kube-proxy`会监视`Kubernetes master`对 Service 对象和 Endpoints 对象的添加和移除



### Service 类型

ClusterIP：通过集群的内部 IP 暴露服务，选择该值，服务只能够在集群内部可以访问，这也是默认的ServiceType。



NodePort：通过每个 Node 节点上的 IP 和静态端口（NodePort）暴露服务

通过请求 :，可以从集群的外部访问一个 NodePort 服务。

（默认：30000-32767）分配端口，每个 Node 将从该端口（每个 Node 上的同一端口）代理到 Service。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myservice
spec:
  selector:
    app: myapp
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    name: myapp-http
    
$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        27d
myservice    NodePort    10.104.57.198   <none>        80:32560/TCP   14h
```



LoadBalancer：使用云提供商的负载局衡器，可以向外部暴露服务



ExternalName：通过返回 CNAME 和它的值，可以将服务映射到 externalName 字段的内容（例如， foo.bar.example.com）。没有任何类型代理被创建，这只有 Kubernetes 1.7 或更高版本的 kube-dns 才支持。

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com
```



## 2. configmap

 `ConfigMap`提供了向容器中注入配置信息的能力，不仅可以用来保存单个属性，也可以用来保存整个配置文件 。

### 创建命令

```
Examples:
  # Create a new configmap named my-config based on folder bar
  kubectl create configmap my-config --from-file=path/to/bar

  # Create a new configmap named my-config with specified keys instead of file basenames on disk
  kubectl create configmap my-config --from-file=key1=/path/to/bar/file1.txt --from-file=key2=/path/to/bar/file2.txt

  # Create a new configmap named my-config with key1=config1 and key2=config2
  kubectl create configmap my-config --from-literal=key1=config1 --from-literal=key2=config2
  
```

对文件目录进行创建：

```

k8s@master testcm]$ ll
total 8
-rw-rw-r-- 1 k8s k8s 25 Oct 12 10:27 mysql.conf
-rw-rw-r-- 1 k8s k8s 25 Oct 12 10:26 redis.conf

[k8s@master testcm]$ kubectl create configmap cm-demo1 --from-file=/home/k8s/testcm
configmap/cm-demo1 created

[k8s@master testcm]$ kubectl get configmap cm-demo1 -o yaml
apiVersion: v1
data:
  mysql.conf: |		#key，文件的名称
    host=127.0.0.1		#value，文件的内容
    port=3306
  redis.conf: |
    host=127.0.0.1
    port=6379
kind: ConfigMap
metadata:
  creationTimestamp: "2019-10-12T02:28:36Z"
  name: cm-demo1
  namespace: default
  resourceVersion: "498343"
  selfLink: /api/v1/namespaces/default/configmaps/cm-demo1
  uid: feb39325-ec97-11e9-8f83-00163e0cd842

```

对某个文件进行创建：

```shell
[k8s@master testcm]$ kubectl create configmap cm-demo2 --from-file=/home/k8s/testcm/redis.conf 
configmap/cm-demo2 created

[k8s@master testcm]$ kubectl get configmap cm-demo2 -o yaml
apiVersion: v1
data:
  redis.conf: |
    host=192.168.4.11
    port=6379
kind: ConfigMap
metadata:
  creationTimestamp: "2019-10-12T02:32:31Z"
  name: cm-demo2
  namespace: default
  resourceVersion: "499124"
  selfLink: /api/v1/namespaces/default/configmaps/cm-demo2
  uid: 8a9a0d29-ec98-11e9-8f83-00163e0cd842
```

使用字符串进行创建

```
[k8s@master testcm]$ kubectl create configmap cm-demo3 --from-literal=db.host=localhost --from-literal=db.port=3306
configmap/cm-demo3 created

[k8s@master testcm]$ kubectl get configmap cm-demo3 -o yaml
apiVersion: v1
data:
  db.host: localhost
  db.port: "3306"
kind: ConfigMap
metadata:
  creationTimestamp: "2019-10-12T02:36:16Z"
  name: cm-demo3
  namespace: default
  resourceVersion: "499868"
  selfLink: /api/v1/namespaces/default/configmaps/cm-demo3
  uid: 109b8f8f-ec99-11e9-8f83-00163e0cd842

```

### 使用

- 设置环境变量的值

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: testcm1-pod
spec:
  containers:
    - name: testcm1
      image: busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: cm-demo3	#configmap的名字
              key: db.host		#key值
        - name: DB_PORT
          valueFrom:
            configMapKeyRef:
              name: cm-demo3
              key: db.port
      envFrom:
        - configMapRef:
            name: cm-demo1
            
[k8s@master testcm]$ kubectl create -f c1.yaml 
pod/testcm1-pod created

[k8s@master testcm]$ kubectl logs testcm1-pod

............
```

- 在容器里设置命令行参数

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: testcm2-pod
spec:
  containers:
    - name: testcm2
      image: busybox
      command: [ "/bin/sh", "-c", "echo $(DB_HOST) $(DB_PORT)" ]
      env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: cm-demo3
              key: db.host
        - name: DB_PORT
          valueFrom:
            configMapKeyRef:
              name: cm-demo3
              key: db.port
```



- 在数据卷里面创建config文件

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: testcm3-pod
spec:
  containers:
    - name: testcm3
      image: busybox
      command: [ "/bin/sh", "-c", "cat /etc/config/redis.conf" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: cm-demo2

[k8s@master testcm]$ kubectl create -f c3.yaml 
pod/testcm3-pod create

[k8s@master testcm]$ kubectl logs testcm3-pod
host=192.168.4.11
port=6379
```

## 3. secret

 一般情况下`ConfigMap`是用来存储一些非安全的配置信息 

 `Secret`用来保存敏感信息，例如密码、OAuth 令牌和 ssh key等等，将这些信息放在`Secret`中比放在`Pod`的定义中或者`docker`镜像中来说更加安全和灵活。 



 `Secret`有三种类型： 

### Opaque Secret

base64 编码格式的 Secret，用来存储密码、密钥等,加密性很弱

Opaque 类型的数据是一个 map 类型，要求value是`base64`编码格式

```shell
[k8s@master testcm]$ echo -n "admin" | base64
YWRtaW4=
[k8s@master testcm]$ echo -n "admin321" | base64
YWRtaW4zMjE=

[k8s@master testcm]$ cat sec-demo.yaml 
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: YWRtaW4zMjE=
  

[k8s@master testcm]$ kubectl create -f sec-demo.yaml 
secret/mysecret created

[k8s@master testcm]$ kubectl get secret mysecret -o yaml
apiVersion: v1
data:
  password: YWRtaW4zMjE=
  username: YWRtaW4=
kind: Secret
metadata:
  creationTimestamp: "2019-10-12T02:49:22Z"
  name: mysecret
  namespace: default
  resourceVersion: "503060"
  selfLink: /api/v1/namespaces/default/secrets/mysecret
  uid: e53033a1-ec9a-11e9-8f83-00163e0cd842
type: Opaque

```

使用

- 以环境变量的形式

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret1-pod
spec:
  containers:
  - name: secret1
    image: busybox
    command: [ "/bin/sh", "-c", "env" ]
    env:
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: username
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: password
          
[k8s@master testcm]$ kubectl create -f s1-pod.yal 
pod/secret1-pod created

[k8s@master testcm]$ kubectl logs secret1-pod

```

- 以Volume的形式挂载

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret2-pod
spec:
  containers:
  - name: secret2
    image: busybox
    command: ["/bin/sh", "-c", "ls /etc/secrets"]
    volumeMounts:
    - name: secrets
      mountPath: /etc/secrets
  volumes:
  - name: secrets
    secret:
     secretName: mysecret

[k8s@master testcm]$ kubectl create -f s2-pod.yaml 
pod/secret2-pod created

[k8s@master testcm]$ kubectl logs secret2-pod
password
username

```

### kubernetes.io/dockerconfigjson

 用来存储私有docker registry的认证信息。 



创建用户`docker registry`认证的`Secret`

```shell
$ kubectl create secret docker-registry myregistry --docker-server=DOCKER_SERVER --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL

```

取私有仓库中的`docker`镜像

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: foo
spec:
  containers:
  - name: foo
    image: 192.168.1.100:5000/test:v1
  imagePullSecrets:
  - name: myregistrykey
```

### kubernetes.io/service-account-token

用于被`serviceaccount`引用

serviceaccout 创建时 Kubernetes 会默认创建对应的 secret。Pod 如果使用了 serviceaccount，对应的secret会自动挂载到Pod的`/run/secrets/kubernetes.io/serviceaccount`目录中



## 4. rbac

`Kubernetes`有一个很基本的特性就是它的[所有资源对象都是模型化的 API 对象](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)，允许执行 CRUD(Create、Read、Update、Delete)操作(也就是我们常说的增、删、改、查操作)，比如下面的这下资源：

- Pods
- ConfigMaps
- Deployments
- Nodes
- Secrets
- Namespaces



- Rule：规则，规则是一组属于不同 API Group 资源上的一组操作的集合
- Role 和 ClusterRole：角色和集群角色，这两个对象都包含上面的 Rules 元素，二者的区别在于，在 Role 中，定义的规则只适用于单个命名空间，也就是和 namespace 关联的，而 ClusterRole 是集群范围内的，因此定义的规则不受命名空间的约束。
- Subject：主题，对应在集群中尝试操作的对象，集群中定义了3种类型的主题资源：
  - User Account：用户，这是有外部独立服务进行管理的，管理员进行私钥的分配，用户可以使用 KeyStone或者 Goolge 帐号，甚至一个用户名和密码的文件列表也可以。对于用户的管理集群内部没有一个关联的资源对象，所以用户不能通过集群内部的 API 来进行管理
  - Group：组，这是用来关联多个账户的，集群中有一些默认创建的组，比如cluster-admin
  - Service Account：服务帐号，通过`Kubernetes` API 来管理的一些用户帐号，和 namespace 进行关联的，适用于集群内部运行的应用程序，需要通过 API 来完成权限认证，所以在集群内部进行权限操作，我们都需要使用到 ServiceAccount，这也是我们这节课的重点
- RoleBinding 和 ClusterRoleBinding：角色绑定和集群角色绑定，简单来说就是把声明的 Subject 和我们的 Role 进行绑定的过程(给某个用户绑定上操作的权限)，二者的区别也是作用范围的区别：RoleBinding 只会影响到当前 namespace 下面的资源操作权限，而 ClusterRoleBinding 会影响到所有的 namespace。



### 创建一个只能访问某个 namespace 的用户

#### 第1步：创建用户凭证	haimaxy

#### 第2步：创建角色 

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: haimaxy-role
  namespace: kube-system
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  
  Pod属于 core 这个 API Group，在YAML中用空字符就可以，而Deployment属于 apps 这个 API Group，ReplicaSets属于extensions这个 API Grou
  
  https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/
  
  $ kubectl create -f haimaxy-role.yaml
  
```

#### 第3步：创建角色权限绑定

在 kube-system 这个命名空间下面将上面的 haimaxy-role 角色和用户 haimaxy 进行绑定:(haimaxy-rolebinding.yaml)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: haimaxy-rolebinding
  namespace: kube-system
subjects:
- kind: User
  name: haimaxy
  apiGroup: ""
roleRef:
  kind: Role
  name: haimaxy-role
  apiGroup: ""
  
  
  $ kubectl create -f haimaxy-rolebinding.yaml
```

#### 第4步. 测试

现在我们应该可以上面的`haimaxy-context`上下文来操作集群了：

```shell
$ kubectl get pods --context=haimaxy-context
....
```

我们可以看到我们使用`kubectl`的使用并没有指定 namespace 了，这是因为我们已经为该用户分配了权限了，如果我们在后面加上一个`-n default`试看看呢？

```shell
$ kubectl --context=haimaxy-context get pods -n default
Error from server (Forbidden): pods is forbidden: User "haimaxy" cannot list pods in the namespace "default"
```

是符合我们预期的吧？因为该用户并没有 default 这个命名空间的操作权限



### (重要常见)创建一个只能访问某个 namespace 的ServiceAccount

首先创建一个 ServiceAccount 对象：

```shell
[k8s@master testcm]$ kubectl create sa log-sa -n logging
serviceaccount/log-sa created

```

再新建一个 Role 对象：(log-sa-role.yaml)

```yaml
[k8s@master testcm]$ vim log-sa-role.yaml
[k8s@master testcm]$ cat log-sa-role.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: log-sa-role
  namespace: logging
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  
[k8s@master testcm]$ kubectl create -f log-sa-role.yaml 
role.rbac.authorization.k8s.io/log-sa-role created

[k8s@master testcm]$ kubectl get role -n logging
NAME          AGE
log-sa-role   12s

```

创建一个 RoleBinding 对象，将上面的 log-sa 和角色 log-sa-role 进行绑定

```yaml
[k8s@master testcm]$ vim log-sa-rolebinding.yaml
[k8s@master testcm]$ cat log-sa-rolebinding.yaml 
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: log-sa-rolebinding
  namespace: logging
subjects:
- kind: ServiceAccount
  name: log-sa
  namespace: logging
roleRef:
  kind: Role
  name: log-sa-role
  apiGroup: rbac.authorization.k8s.io
  
[k8s@master testcm]$ kubectl create -f log-sa-rolebinding.yaml 
rolebinding.rbac.authorization.k8s.io/log-sa-rolebinding created

[k8s@master testcm]$ kubectl get RoleBinding -n logging
NAME                 AGE
log-sa-rolebinding   18s

```

### 创建一个可以访问所有 namespace 的ServiceAccount

首先新建一个 ServiceAcount 对象

```yaml
(log-sa2.yaml)

apiVersion: v1
kind: ServiceAccount
metadata:
  name: log-sa2
  namespace: logging
  
  
[k8s@master testcm]$ vim log-sa2.yaml
[k8s@master testcm]$ kubectl create -f log-sa2.yaml 
serviceaccount/log-sa2 created
[k8s@master testcm]$ kubectl get sa -n logging
NAME         SECRETS   AGE
default      1         20h
fluentd-es   1         20h
log-sa       1         13m
log-sa2      1         7s

```

创建一个 ClusterRoleBinding 对象(log-sa2-clusterolebinding.yaml):

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: log-sa2-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: log-sa2
  namespace: logging
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
  
  
  这是一个 ClusterRoleBinding 资源对象，是作用于整个集群的，我们也没有单独新建一个 ClusterRole 对象，而是使用的 cluster-admin 这个对象，这是Kubernetes集群内置的 ClusterRole 对象，
  cluster-admin 这个集群角色是拥有最高权限的集群角色，所以一般需要谨慎使用该集群角色
  
  [k8s@master testcm]$ vim log-sa2-clusterrolebingding.yaml
  
[k8s@master testcm]$ kubectl create -f log-sa2-clusterrolebingding.yaml 
clusterrolebinding.rbac.authorization.k8s.io/log-sa2-clusterrolebinding created

  
  [k8s@master testcm]$ kubectl get -n logging ClusterRoleBinding|grep log
log-sa2-clusterrolebinding 
```

## 5. daemonset

Daemon，就是用来部署守护进程的，

`DaemonSet`用于在每个`Kubernetes`节点中将守护进程的副本作为后台进程运行，说白了就是在每个节点部署一个`Pod`副本，当节点加入到`Kubernetes`集群中，`Pod`会被调度到该节点上运行，当节点从集群只能够被移除后，该节点上的这个`Pod`也会被移除，当然，如果我们删除`DaemonSet`，所有和这个对象相关的`Pods`都会被删除



- 集群存储守护程序，如`glusterd`、`ceph`要部署在每个节点上以提供持久性存储；
- 节点监视守护进程，如`Prometheus`监控集群，可以在每个节点上运行一个`node-exporter`进程来收集监控节点的信息；
- 日志收集守护程序，如`fluentd`或`logstash`，在每个节点上运行以收集容器的日志



`DaemonSet`并不关心一个节点的`unshedulable`字段

`DaemonSet`可以创建`Pod`，即使调度器还没有启动





## 6. statefulset



无状态服务（Stateless Service）：该服务运行的实例不会在本地存储需要持久化的数据，并且多个实例对于同一个请求响应的结果是完全一致的



有状态服务（Stateful Service）：就和上面的概念是对立的了，该服务运行的实例需要在本地存储持久化数据，比如上面的`MySQL`数据库



StatefulSet：

- 稳定的、唯一的网络标识符
- 稳定的、持久化的存储
- 有序的、优雅的部署和缩放
- 有序的、优雅的删除和终止
- 有序的、自动滚动更新



### 检查 Pod 的顺序索引

​	 StatefulSet 中的 Pod 拥有一个具有稳定的、独一无二的身份标志

​	Pod 的名称的形式为`<statefulset name>-<ordinal index>`



### 使用稳定的网络身份标识

对于一些特定的服务，我们可能会使用更加高级的 Operator 来部署，比如 etcd-operator、prometheus-operator 等等，这些应用都能够很好的来管理有状态的服务，而不是单纯的使用一个 StatefulSet 来部署一个 Pod就行，因为对于有状态的应用最重要的还是数据恢复、故障转移等等。



### statefulset作用

就是，使用pod模板创建pod时候，对他们进行编号，并且按照编号顺序逐一完成创建工作

当statefulset 发现pod的实际状态与期望状态不一致，需要新建或者删除，pod进行“调谐”的时候，会

严格按照pod编号的顺序进行操作；



### statefulset 的工作原理 

	1. stateful的控制器直接管理的是pod，通过在pod名字里加上事先约定好的编号
	
	2. k8s通过headless service，为这些有编号的pod，在dns服务器中生成带有同样编号的DNS记录
	
	3. statefulset还为每一个pod分配并创建同样编号的PVC；
