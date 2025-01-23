* https://www.elastic.co/guide/en/beats/filebeat/current/running-on-kubernetes.html
* https://arch-long.cn/articles/elasticsearch/FileBeat.html
* https://www.cnblogs.com/cjsblog/p/9495024.html
* https://blog.csdn.net/yanggd1987/article/details/108414587
  
* 下载filebeat-kubernetes.yaml
```
curl -L -O https://raw.githubusercontent.com/elastic/beats/7.10/deploy/kubernetes/filebeat-kubernetes.yaml
```

* vim filebeat-kubernetes.yaml
```yml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: filebeat-config
  namespace: kube-system
  labels:
    k8s-app: filebeat
data:
  filebeat.yml: |-
    filebeat.inputs:
    - type: container
      paths:
        - /var/log/containers/*hardware-middleware*.log
      fields:
        service: "hardware-middleware"
    - type: container
      paths:
        - /var/log/containers/*hotel-members*.log
      fields:
        service: "hotel-members"
    - type: container
      harvester_buffer_size: 1638400   #harvester读取文件的缓冲大小
      paths:
        - /var/log/containers/*hotel-rights*.log
      fields:
        service: "hotel-rights"

    - type: log
      harvester_buffer_size: 1638400   #harvester读取文件的缓冲大小
      paths:
        - /fdata/email-api/**/*.log*
      fields:
        website: "email-api"
      # 将不匹配的行添加到匹配的行后面
      multiline.type: pattern
      multiline.pattern: '^\[[0-9]{4}-[0-9]{2}-[0-9]{2}'
      multiline.negate: true  #true表示对上面的pattern取反（即不匹配上面pattern的日志行）
      multiline.match: after  #添加到匹配日志行的后面

    - type: log
      paths:
        - /fdata/openresty/access.*.log
      fields:
        website: "openresty-access"

      # 这些选项使Filebeat能够解码结构为JSON消息的日志。Filebeat逐行处理日志，因此JSON解码只有在每行有一个JSON对象时才有效
      json.keys_under_root: true   #默认情况下，解码后的JSON放在输出文档中的“JSON”键下。如果启用此设置，则在输出文档的顶层复制密钥。默认为false。
      json.overwrite_keys: true    #如果keys_under_root被启用，那么在key冲突的情况下，解码后的JSON对象将覆盖Filebeat正常的字段
      json.message_key: http_x_forwarded_for  #(可选配置)它指定一个JSON键，在该键上应用行过滤和多行设置。如果指定了键，则键必须位于JSON对象的顶层，并且与键关联的值必须是字符串，否则不会发生过滤或多行聚合。
      json.message_key: http_user_agent
      exclude_lines: ['^ELB-HealthChecker','^kube-probe']
    
    processors:
      # - add_cloud_metadata:
      # - add_host_metadata:
      - add_kubernetes_metadata:
          host: ${NODE_NAME}
          matchers:
          - logs_path:
              logs_path: "/var/log/containers/"
      - drop_fields:
          fields: ["log", "prospector", "agent", "input", "beat", "offset"]
          ignore_missing: true
      - add_fields:
          fields:
            env: "prod"

    cloud.id: ${ELASTIC_CLOUD_ID}
    cloud.auth: ${ELASTIC_CLOUD_AUTH}
    

    setup.ilm.enabled: false       #关闭索引生命周期管理（否则无法创建自定义索引）
    setup.template.enabled: false  #关闭elasticsearch默认索引模板（否则无法修改默认索引名）
    #setup.template.name: "k8s-"
    #setup.template.pattern: "k8s-*"

    output.elasticsearch:
      hosts: ['${ELASTICSEARCH_HOST:elasticsearch}:${ELASTICSEARCH_PORT:9200}']
      #index: "k8s-%{[kubernetes][labels][app_kubernetes_io/name]}-%{+YYYY.MM.dd}"
      #username: ${ELASTICSEARCH_USERNAME}
      #password: ${ELASTICSEARCH_PASSWORD}
      bulk_max_size: 1000      #向es一次输出的日志量
      worker: 3                #根据elasticsearch节点数来设置
      indices:
        - index: "hardware-middleware-%{+YYYY.MM.dd}"
          when.equals:
            fields.service: "hardware-middleware"
        - index: "hotel-members-%{+YYYY.MM.dd}"
          when.equals:
            fields.service: "hotel-members"
        - index: "hotel-rights-%{+YYYY.MM.dd}"
          when.equals:
            fields.service: "hotel-rights"
        - index: "email-api-%{+YYYY.MM.dd}"
          when.equals:
            fields.website: "email-api"
        - index: "openresty-access-%{+YYYY.MM.dd}"
          when.equals:
            fields.website: "openresty-access"
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: filebeat
  namespace: kube-system
  labels:
    k8s-app: filebeat
spec:
  selector:
    matchLabels:
      k8s-app: filebeat
  template:
    metadata:
      labels:
        k8s-app: filebeat
    spec:
      serviceAccountName: filebeat
      terminationGracePeriodSeconds: 30
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      containers:
      - name: filebeat
        image: docker.elastic.co/beats/filebeat:7.10.0
        args: [
          "-c", "/etc/filebeat.yml",
          "-e",
        ]
        env:
        - name: ELASTICSEARCH_HOST
          value: 10.12.0.116       #elasticsearch主机IP
        - name: ELASTICSEARCH_PORT
          value: "9200"
        - name: ELASTICSEARCH_USERNAME
          value: "elastic"
        - name: ELASTICSEARCH_PASSWORD
          value: ""
        - name: ELASTIC_CLOUD_ID
          value:
        - name: ELASTIC_CLOUD_AUTH
          value:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        securityContext:
          runAsUser: 0
          # If using Red Hat OpenShift uncomment this:
          #privileged: true
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 100Mi
        volumeMounts:
        - name: config
          mountPath: /etc/filebeat.yml
          readOnly: true
          subPath: filebeat.yml
        - name: data
          mountPath: /usr/share/filebeat/data
        - name: varlibdockercontainers
          mountPath: /data/docker/containers #修改docker data目录
          readOnly: true
        - name: varlog
          mountPath: /var/log
          readOnly: true
      volumes:
      - name: config
        configMap:
          defaultMode: 0640
          name: filebeat-config
      - name: varlibdockercontainers
        hostPath:
          path: /data/docker/containers   #修改docker data目录
      - name: varlog
        hostPath:
          path: /var/log
      # data folder stores a registry of read status for all files, so we don't send everything again on a Filebeat pod restart
      - name: data
        hostPath:
          # When filebeat runs as non-root user, this directory needs to be writable by group (g+w).
          path: /data/filebeat-data  #修改filebeat data目录
          type: DirectoryOrCreate
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: filebeat
subjects:
- kind: ServiceAccount
  name: filebeat
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: filebeat
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: filebeat
  labels:
    k8s-app: filebeat
rules:
- apiGroups: [""] # "" indicates the core API group
  resources:
  - namespaces
  - pods
  verbs:
  - get
  - watch
  - list
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: filebeat
  namespace: kube-system
  labels:
    k8s-app: filebeat
---

```
```
kubectl apply -f filebeat-kubernetes.yaml
```