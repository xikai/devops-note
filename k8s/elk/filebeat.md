* https://zhuanlan.zhihu.com/p/114510384
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
      paths:
        - /var/log/containers/*hotel-rights*.log
      fields:
        service: "hotel-rights"

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