* https://github.com/hipages/php-fpm_exporter
* https://github.com/bakins/php-fpm-exporter
* https://www.cnblogs.com/91donkey/p/14035441.html
* https://www.jianshu.com/p/0d0439e03e08

# 部署php-fpm-exporter
### 开启php-fpm status页面
* vim php-fpm.conf
```
listen = /run/php/php7-fpm.sock
pm.status_path = /php-status
ping.path = /ping
```

### 添加php-fpm-exporter容器到php pod
```yml
apiVersion: apps/v1
kind: Deployment
……
    spec:
      volumes:
        - name: phpsock
          emptyDir: {}
      containers:
      - name: phpfpm-exporter
        image: hipages/php-fpm_exporter
        imagePullPolicy: IfNotPresent
        env:
          - name: PHP_FPM_SCRAPE_URI
            value: "unix:/run/php/php7-fpm.sock;/php-status"
          - name: PHP_FPM_FIX_PROCESS_COUNT
            value: "true"
        ports:
        - containerPort: 9253
          name: metric-port
        volumeMounts:
          - name: phpsock
            mountPath: /run/php
            subPath: phpsock
```
* 获取phpfpm status信息
```
# 默认请求（PHP_FPM_SCRAPE_URI）
php-fpm_exporter get

# 指定获取地址
php-fpm_exporter get --phpfpm.scrape-uri tcp://127.0.0.1:9000/status,tcp://127.0.0.1:9001/status
```


# k8s 自动发现php pod
### deployment中添加注解<prometheus.io/scrape: php-fpm>,以便promtheus过滤label来抓取指定target
```yml
apiVersion: apps/v1
kind: Deployment
……
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: php-fpm
```

### 配置php-fpm-exporter metrics scrape配置
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
      replacement: ${1}:9253
    - action: labelmap
      regex: __meta_kubernetes_pod_label_(.+)
    - source_labels: [__meta_kubernetes_namespace]
      target_label: kubernetes_namespace
    - source_labels: [__meta_kubernetes_pod_name]
      target_label: app
```

* 更新promtheus附加配置
```
# 修改prometheus-additional.yaml需要更新secret
kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run -oyaml |kubectl apply -n monitoring -f -

#查看secret for additional-scrape-configs
kubectl get secret additional-scrape-configs -n monitoring -oyaml |yq '.data ."prometheus-additional.yaml"' - |base64 -di
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
```yml
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