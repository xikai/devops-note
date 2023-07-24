* https://github.com/prometheus-community/elasticsearch_exporter

# [部署elasticsearch_exporter](https://github.com/prometheus-community/elasticsearch_exporter/blob/master/examples/kubernetes/deployment.yml)
* vim  config/es-exporter.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: es-exporter-svc
  namespace: monitoring
spec:
  selector:
    k8s-app: es-exporter
  ports:
  - name: svc-9114
    protocol: TCP
    port: 9114
    targetPort: 9114
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: es-exporter
  namespace: monitoring
spec:
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  selector:
    matchLabels:
      k8s-app: es-exporter
  template:
    metadata:
      labels:
        k8s-app: es-exporter
    spec:
      containers:
        - name: es-exporter
          image: quay.io/prometheuscommunity/elasticsearch-exporter:latest
          command:
            - /bin/elasticsearch_exporter
            - --es.uri=http://elasticsearch:9200  #被采集es集群的一个节点
            - --es.all  #采集集群所有节点，不仅是本节点
            - --es.cluster_settings
            - --es.indices
            - --es.indices_settings
            - --es.indices_mappings	
            - --es.shards
            - --es.snapshots
          ports:
            - containerPort: 9114
              name: http
          securityContext:
            capabilities:
              drop:
                - SETPCAP
                - MKNOD
                - AUDIT_WRITE
                - CHOWN
                - NET_RAW
                - DAC_OVERRIDE
                - FOWNER
                - FSETID
                - KILL
                - SETGID
                - SETUID
                - NET_BIND_SERVICE
                - SYS_CHROOT
                - SETFCAP
            readOnlyRootFilesystem: true
          livenessProbe:
            httpGet:
              path: /healthz
              port: 9114
            initialDelaySeconds: 30
            timeoutSeconds: 10
          readinessProbe:
            httpGet:
              path: /healthz
              port: 9114
            initialDelaySeconds: 10
            timeoutSeconds: 10
          resources:
            limits:
              cpu: 100m
              memory: 128Mi
            requests:
              cpu: 25m
              memory: 64Mi
      restartPolicy: Always
      securityContext:
        runAsNonRoot: true
        runAsGroup: 10000
        runAsUser: 10000
        fsGroup: 10000
```
```
kubectl apply -f config/es-exporter.yaml
```

# 配置prometheus
* vim config/prometheus-additional.yaml
```yml
- job_name: 'es_exporter'
  static_configs:
    - targets:
      - es-exporter-svc:9114
```

* 更新promtheus附加配置
```
# 修改prometheus-additional.yaml需要更新secret
kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run -oyaml |kubectl apply -n monitoring -f -

#查看secret for additional-scrape-configs
kubectl get secret additional-scrape-configs -n monitoring -oyaml |yq e '.data ."prometheus-additional.yaml"' - |base64 -d
```

# elasticsearch dashboard
* https://grafana.com/grafana/dashboards/6483

# alert
* https://www.cnblogs.com/xibuhaohao/p/11156830.html