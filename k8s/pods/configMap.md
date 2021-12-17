* https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
* congfigMap对象和secret对象类似，congfigMap对象存储不敏感的数据
* 当一个已经被使用的 ConfigMap 发生了更新时，对应的 Key 也会被更新，Kubelet 会周期性的使用本地基于 ttl 的 cache 来获取 ConfigMap 的当前内容
* ConfigMaps 存在于指定的 命名空间.

### 命令创建configMap对象
* 使用目录创建configMap
```
mkdir -p configure-pod-container/configmap/kubectl/
wget https://k8s.io/docs/tasks/configure-pod-container/configmap/kubectl/game.properties -O configure-pod-container/configmap/kubectl/game.properties
wget https://k8s.io/docs/tasks/configure-pod-container/configmap/kubectl/ui.properties -O configure-pod-container/configmap/kubectl/ui.properties
kubectl create configmap game-config --from-file=configure-pod-container/configmap/kubectl/
```

* 使用文件创建configMap
```
#单个文件
kubectl create configmap game-config-2 --from-file=configure-pod-container/configmap/kubectl/game.properties
#多个文件
kubectl create configmap game-config-2 --from-file=configure-pod-container/configmap/kubectl/game.properties --from-file=configure-pod-container/configmap/kubectl/ui.properties
# 指定key替代文件名
kubectl create configmap game-config-3 --from-file=game-special-key=docs/user-guide/configmap/kubectl/game.properties
```

* 使用用字面值创建ConfigMap
```
kubectl create configmap special-config --from-literal=special.how=very --from-literal=special.type=charm
```

* 查看configMap对象
```
kubectl describe configmaps game-config
kubectl get configmaps game-config -o yaml
```

### yaml创建ConfigMap对象
* 创建字符串类型ConfigMap对象
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  SPECIAL_LEVEL: very
  SPECIAL_TYPE: charm
```

### pod中使用ConfigMap
* envFrom 将 ConfigMap 中的所有键值对配置为容器环境变量
```yml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "env" ]
      envFrom:
      - configMapRef:
          name: special-config
  restartPolicy: Never
```

* env.valueFrom 使用来自 ConfigMap 的数据定义容器环境变量
```yml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        # Define the environment variable
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              # The ConfigMap containing the value you want to assign to SPECIAL_LEVEL_KEY
              name: special-config
              # Specify the key associated with the value
              key: SPECIAL_LEVEL
  restartPolicy: Never
```

* 将 ConfigMap 数据添加到一个卷中
```yml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "ls /etc/config/" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        # Provide the name of the ConfigMap containing the files you want
        # to add to the container
        name: special-config
  restartPolicy: Never
```

* 将ConfigMap 里的指定数据生成一个卷
```yml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh","-c","cat /etc/config/keys" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: special-config
        items:
        - key: SPECIAL_LEVEL
          path: keys
  restartPolicy: Never
```


