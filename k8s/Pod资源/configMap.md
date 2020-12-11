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
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  special.how: very
  SPECIAL_TYPE: charm
```
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  nginx.conf: |-
    user  nginx;
    worker_processes  auto;

    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;


    events {
        worker_connections  1024;
    }


    http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;

        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                          '$status $body_bytes_sent "$http_referer" '
                          '"$http_user_agent" "$http_x_forwarded_for"';

        access_log  /var/log/nginx/access.log  main;

        sendfile        on;
        #tcp_nopush     on;

        keepalive_timeout  65;

        #gzip  on;

        resolver 10.96.0.10;
        include /etc/nginx/conf.d/*.conf;
    }
```


* 将ConfigMap 里的数据指定为文件
```
{{- if .Values.nginx -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-nginx-conf
  labels:
    app: {{ .Release.Name }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    heritage: {{ .Release.Service }}
    release: {{ .Release.Name }}
data:
{{ (.Files.Glob "files/nginx.conf").AsConfig | indent 2 }}
{{- if eq .Values.deploy_env "test" }}
{{ (.Files.Glob "files/nginx-vhosts-test.conf").AsConfig | indent 2 }}
{{- end }}
```

### pod中使用ConfigMap
* 使用ConfigMap数据定义容器环境变量（valueFrom）
```
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
              key: special.how
  restartPolicy: Never
```

* 将所有 ConfigMap 的键值对都设置为Pod的环境变量（envFrom）
```
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

* 在 Pod 命令里使用 ConfigMap 定义的环境变量（$(VAR_NAME)替换变量）
```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "echo $(SPECIAL_LEVEL_KEY) $(SPECIAL_TYPE_KEY)" ]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special_level
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special_type
  restartPolicy: Never

```

* 从 ConfigMap 里的数据生成一个卷
```
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
```
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
        - key: special.level
          path: keys
  restartPolicy: Never
```


