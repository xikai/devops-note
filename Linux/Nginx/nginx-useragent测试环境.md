# nginx user-agent配置
1. 通过user_agent代理到不同的upstream
```
upstream example_www {
    server  example-www-svc.frontend.svc.cluster.local max_fails=2 fail_timeout=30s;
}
upstream upstream_ua {
    server  example-ua-svc.frontend.svc.cluster.local max_fails=2 fail_timeout=30s;
}

server {
    listen 80;
    server_name www.example.com;

    set $server_www http://upstream_www;
    if ( $http_user_agent ~ ua_(.*) ){
        set $server_www http://upstream_ua;
    }

    location / {
        proxy_pass $server_www;
    }
```

2. 通过获取user_agent指定不同的代码目录
```
    server {
      listen       80;
      server_name  www.example.com;

      set $ua "default";
      if ( $http_user_agent ~ ua_(.*) ){
          set $ua $http_user_agent;
      }
      root "/var/www/html/$ua/example_www/public";

    }
```
```
# 创建k8s service
example-ua-svc
```

# example-ua pod挂载ua代码
```
      volumes:
        - name: nginx-vhost
          configMap: 
            name: example-ua-nginx-vhost
        - name: efs-config
          persistentVolumeClaim:
            claimName: example-ua-efs
        #- name: nfs-vol
        #  nfs:
        #    path: /data/code/web
        #    server: 172.28.46.242
```

# 发布构建ua环境代码
```
1. git pull代码
2. 编译构建
3. 将编译后的 当前工作目录代码部署到 文件存储服务(efs/nfs)
```

# 浏览器user-agent插件
```
User-Agent Switcher for Chrome
```