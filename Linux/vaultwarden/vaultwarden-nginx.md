> 通过阿里云申请免费ssl证书

* [配置代理](https://github.com/dani-garcia/vaultwarden/wiki/Proxy-examples) ,vim /opt/vaultwarden/nginx/conf.d/vaultwarden.conf
```sh
server {
    listen 80;
    server_name vault.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name vault.example.com;

    ssl_certificate cert/vault.example.com.pem;
    ssl_certificate_key cert/vault.example.com.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;

    client_max_body_size 128M;

    location / {
        proxy_http_version 1.1;
        proxy_set_header "Connection" "";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_pass http://vaultwarden;
    }

    location /notifications/hub/negotiate {
        proxy_http_version 1.1;
        proxy_set_header "Connection" "";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_pass http://vaultwarden;
    }

    location /notifications/hub {
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Forwarded $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_pass http://vaultwarden:3012;
    }

    # Optionally add extra authentication besides the ADMIN_TOKEN
    # Remove the comments below `#` and create the htpasswd_file to have it active
    #
    #location /admin {
    #   # See: https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/
    #   auth_basic "Private";
    #   auth_basic_user_file /path/to/htpasswd_file;
    #   
    #   proxy_http_version 1.1;
    #   proxy_set_header "Connection" "";
    #   
    #   proxy_set_header Host $host;
    #   proxy_set_header X-Real-IP $remote_addr;
    #   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #   proxy_set_header X-Forwarded-Proto $scheme;
    #   
    #   proxy_pass http://vaultwarden;
    #}
}

```

* vim /opt/vaultwarden/docker-compose.yml
```yml
version: '3'

services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    environment:
      WEBSOCKET_ENABLED: "true"
      DOMAIN: "https://vault.example.com"  #注意，如果启用了SMTP和邀请，将通过电子邮件向新用户发送邀请。您必须使用vault实例的基本URL设置DOMAIN配置选项，以便正确生成邀请链接。
      ADMIN_TOKEN: "l8FOfRwtcxPEpRYSUjwblerUt8dU6b/xxxxxxxxxxxxxxxxxxxxxxx"   #openssl rand -base64 48 生成48位随机字符串
      SMTP_HOST: "<smtp.domain.tld>"
      SMTP_FROM: "<vaultwarden@domain.tld>"
      SMTP_PORT: 587                      #SMTP_SECURITY: "starttls"，端口为587
      SMTP_SECURITY: "starttls"
      SMTP_USERNAME: "<username>"
      SMTP_PASSWORD: "<password>"
    volumes:
      - ./vw-data:/data

  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d/:ro
      - ./nginx/cert:/etc/nginx/cert/:ro
    depends_on:
      - vaultwarden
```

```
docker-compose up -d
```