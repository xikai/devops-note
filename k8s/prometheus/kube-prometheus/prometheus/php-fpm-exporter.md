* https://github.com/hipages/php-fpm_exporter
* https://www.cnblogs.com/91donkey/p/14035441.html
* https://www.jianshu.com/p/0d0439e03e08

# 开启php-fpm status页面
* vim php-fpm.conf
```
pm.status_path = /phpfpm_status
ping.path = /ping
```
* vim /etc/nginx/conf.d/phpfpm-status.conf
```
server {
    listen 80;
    server_name localhost;

    location ~ ^/(phpfpm_status|ping)$ {
        fastcgi_pass unix:/tmp/php-cgi.sock;
        #fastcgi_pass  127.0.0.1:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        access_log off;
        allow 127.0.0.1;
        allow 10.20.0.0/16;
        deny all;
    }
}
```
* php-fpm deployment中添加注解,以便promtheus过滤label来抓取指定target
```yml
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: php-fpm
```

# 部署php-fpm-exporter
```yml
apiVersion: v1
kind: Service
metadata:
  name: phpfpm-exporter-svc
  namespace: monitoring
spec:
  selector:
    k8s-app: phpfpm-exporter
  ports:
  - name: svc-9253
    protocol: TCP
    port: 9253
    targetPort: 9253
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpfpm-exporter
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: phpfpm-exporter
  template:
    metadata:
      labels:
        k8s-app: phpfpm-exporter
    spec:
      containers:
      #- name: phpfpm
      #  image: hipages/php
      #  imagePullPolicy: IfNotPresent
      #  env:
      #    - name: PHP_FPM_PM_STATUS_PATH
      #      value: "/status"
      - name: phpfpm-exporter
        image: hipages/php-fpm_exporter
        imagePullPolicy: IfNotPresent
        #env:
        #  - name: PHP_FPM_SCRAPE_URI
        #    value: "tcp://phpfpm:9000/status"
        #  - name: PHP_FPM_FIX_PROCESS_COUNT
        #    value: "true"
        ports:
        - containerPort: 9253
          name: metric-port
        securityContext:
          privileged: false
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
```
```
kubectl apply -f php-fpm-exporter.yaml
```

### 增加php-fpm-exporter metrics scrape配置
* vim manifests/additional/prometheus-additional.yaml
```yml
- job_name: "phpfpm_exporter_targets"
  kubernetes_sd_configs:
    - role: pod
  metrics_path: /metrics
  relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: php-fpm
    - source_labels: [__meta_kubernetes_pod_ip]
      action: replace
      regex: (.+)
      target_label: __address__
      replacement: http://${1}/phpfpm-status
    - action: labelmap
      regex: __meta_kubernetes_pod_label_(.+)
    - source_labels: [__meta_kubernetes_namespace]
      target_label: kubernetes_namespace
    - source_labels: [__meta_kubernetes_pod_name]
      target_label: kubernetes_pod_name
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - source_labels: [__param_target]
      target_label: scrape_uri
    - target_label: __address__
      replacement: phpfpm-exporter-svc:9253

## config for scraping the exporter itself
- job_name: 'phpfpm_exporter_itself'
  static_configs:
    - targets:
      - phpfpm-exporter-svc:9253
```

* 更新promtheus附加配置
```
# 修改prometheus-additional.yaml需要更新secret
kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run -oyaml |kubectl apply -n monitoring -f -

#查看secret for additional-scrape-configs
kubectl get secret additional-scrape-configs -n monitoring -oyaml |yq e '.data ."prometheus-additional.yaml"' - |base64 -d
```


# troubleshooting: 无法抓取目标
* 查看prometheus日志
```
kubectl logs prometheus-k8s-0 -n monitoring -c prometheus
```
```
# RBAC用户 system:serviceaccount:monitoring:prometheus-k8s 没有权限列出pods
level=error ts=2021-12-23T10:34:13.887Z caller=klog.go:116 component=k8s_client_runtime func=ErrorDepth msg="pkg/mod/k8s.io/client-go@v0.22.1/tools/cache/reflector.go:167: Failed to watch *v1.Pod: failed to list *v1.Pod: pods is forbidden: User \"system:serviceaccount:monitoring:prometheus-k8s\" cannot list resource \"pods\" in API group \"\" at the cluster scope"
```
* vim prometheus-clusterRole.yaml
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/component: prometheus
    app.kubernetes.io/name: prometheus
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 2.30.3
  name: prometheus-k8s
rules:
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
- nonResourceURLs:
  - /metrics
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - services
  - pods
  - endpoints
  verbs:
  - get
  - list
  - watch
```
```
kubectl apply -f prometheus-clusterRole.yaml
```

# Grafana Dasbhoard
* https://grafana.com/dashboards/4912