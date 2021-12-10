* 参考文档
```
# kubernetes efk yaml:
https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch

# elastic efk
https://github.com/elastic/helm-charts
```

* 添加elastic helm chart源
```
helm repo add elastic https://helm.elastic.co
```

### 部署elasticsearch
* 创建自定义values
> vim es-values.yaml
```
volumeClaimTemplate:
  accessModes: [ "ReadWriteOnce" ]
  storageClassName: "alicloud-disk-ssd-shenzhen-a"
  resources:
    requests:
      storage: 20Gi    #阿里云盘最小20GB

antiAffinity: ""       #取消反亲和性，在同一个节点运行多个相同pod

esJavaOpts: "-Xmx256m -Xms256m"

resources:
  requests:
    cpu: "100m"
    memory: "256Mi"
  limits:
    cpu: "1000m"
    memory: "512Mi"
```

* helm安装elasticsearch集群
```
helm install --name es elastic/elasticsearch -f es-values.yaml
```

### 部署kibana
* 创建自定义values
> vim kibana.yaml
```
resources:
  requests:
    cpu: "100m"
    memory: "256Mi"
  limits:
    cpu: "1000m"
    memory: "512Mi"
    
ingress:
  enabled: enable
  annotations:
    kubernetes.io/ingress.class: "traefik"
  path: /
  hosts:
    - logk8.dadi01.net
```
* helm安装kibana
```
helm install --name kibana elastic/kibana -f kibana.yaml
```

---
### 部署fluentd
* https://github.com/helm/charts/tree/master/stable/fluentd
* 创建自定义values
> vim fluentd.yaml
```
image:
  repository: registry.cn-shenzhen.aliyuncs.com/ihuat/fluentd-elasticsearch
  tag: v2.2.0
  pullPolicy: IfNotPresent

output:
  host: 172.18.232.26
  port: 9200
  scheme: http
  sslVersion: TLSv1
  buffer_chunk_limit: 2M
  buffer_queue_limit: 8

service:
  annotations: {}
  type: ClusterIP
  # type: NodePort
  # nodePort:
  # Used to create Service records
  ports:
    - name: "monitor-agent"
      protocol: TCP
      containerPort: 24220
    - name: "fluentd-agent"
      protocol: TCP
      containerPort: 24224
  
configMaps:
  general.conf: |
    # Prevent fluentd from handling records containing its own logs. Otherwise
    # it can lead to an infinite loop, when error in sending one message generates
    # another message which also fails to be sent and so on.
    <match fluentd.**>
      @type null
    </match>

    # Used for health checking
    <source>
      @type http
      port 9880
      bind 0.0.0.0
    </source>

    # Emits internal metrics to every minute, and also exposes them on port
    # 24220. Useful for determining if an output plugin is retryring/erroring,
    # or determining the buffer queue length.
    <source>
      @type monitor_agent
      bind 0.0.0.0
      port 24220
      tag fluentd.monitor.metrics
    </source>
  system.conf: |-
    <system>
      root_dir /tmp/fluentd-buffers/
    </system>
  forward-input.conf: |
    <source>
      @type forward
      port 24224
      bind 0.0.0.0
    </source>
  output.conf: |
    <match **.**>
      @id elasticsearch
      @type elasticsearch
      @log_level info
      include_tag_key false
      # Replace with the host/port to your Elasticsearch cluster.
      host "#{ENV['OUTPUT_HOST']}"
      port "#{ENV['OUTPUT_PORT']}"
      scheme "#{ENV['OUTPUT_SCHEME']}"
      ssl_version "#{ENV['OUTPUT_SSL_VERSION']}"
      logstash_format true
      <buffer>
        @type file
        path /var/log/fluentd-buffers/kubernetes.system.buffer
        flush_mode interval
        retry_type exponential_backoff
        flush_thread_count 2
        flush_interval 5s
        retry_forever
        retry_max_interval 30
        chunk_limit_size "#{ENV['OUTPUT_BUFFER_CHUNK_LIMIT']}"
        queue_limit_length "#{ENV['OUTPUT_BUFFER_QUEUE_LIMIT']}"
        overflow_action block
      </buffer>
    </match>
```
* helm安装fluentd
```
helm install --name fluentd stable/fluentd -f fluentd.yaml
```