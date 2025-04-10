# vaultwarden (bitwarden开源版)
* https://github.com/dani-garcia/vaultwarden/wiki
* [bitwarden官方版，需要购买licensing使用付费功能（不推荐）](https://bitwarden.com/help/hosting-faqs/#q-what-are-my-installation-id-and-installation-key-used-for)
* [Let’s Encrypt颁发ssl证书](../lets-encrypt.md)

# [Caddy with HTTP challenge部署(不推荐，需要让公网可以访问域名)](https://github.com/dani-garcia/vaultwarden/wiki/Using-Docker-Compose#caddy-with-http-challenge)
> that you have a domain name (e.g., vaultwarden.example.com) for your vaultwarden instance, and that it will <font color=red>be publicly accessible.</font>

* vim /opt/vaultwarden/Caddyfile
```json
{$DOMAIN}:443 {
  log {
    level INFO
    output file {$LOG_FILE} {
      roll_size 10MB
      roll_keep 10
    }
  }

  # Use the ACME HTTP-01 challenge to get a cert for the configured domain.
  tls {$EMAIL}

  # This setting may have compatibility issues with some browsers
  # (e.g., attachment downloading on Firefox). Try disabling this
  # if you encounter issues.
  encode gzip

  # Notifications redirected to the WebSocket server
  reverse_proxy /notifications/hub vaultwarden:3012

  # Proxy everything else to Rocket
  reverse_proxy vaultwarden:80 {
       # Send the true remote IP to Rocket, so that vaultwarden can put this in the
       # log, so that fail2ban can ban the correct IP.
       header_up X-Real-IP {remote_host}
  }
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
      WEBSOCKET_ENABLED: "true"  # Enable WebSocket notifications.
    volumes:
      - ./vw-data:/data

  caddy:
    image: caddy:2
    container_name: caddy
    restart: always
    ports:
      - 80:80  # Needed for the ACME HTTP-01 challenge.
      - 443:443
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy-config:/config
      - ./caddy-data:/data
    environment:
      DOMAIN: "https://vaultwarden.example.com"  # Your domain.
      EMAIL: "admin@example.com"                 # The email address to use for ACME registration.
      LOG_FILE: "/data/caddy/access.log"
```

# [使用 Let's Encrypt 证书运行私有 vaultwarden 实例](https://github.com/dani-garcia/vaultwarden/wiki/Running-a-private-vaultwarden-instance-with-Let%27s-Encrypt-certs)
>假设您想要运行一个只能从您的本地网络访问的 vaultwarden 实例，但您希望您的实例启用 HTTPS，并使用由广泛接受的 CA 签名的证书，而不是管理您自己的私有 CA（以避免麻烦必须将私有 CA 证书加载到您的所有设备中）
### [自定义构建caddy](https://github.com/dani-garcia/vaultwarden/wiki/Running-a-private-vaultwarden-instance-with-Let%27s-Encrypt-certs#getting-a-custom-caddy-build)
> 默认情况下，Caddy 不内置 DNS challenge支持，因为大多数人不使用这种质询方法，并且它需要为每个 DNS 提供商自定义实现
1. [下载](https://caddyserver.com/download)caddy for godaddy - [caddy-dns/godaddy](https://github.com/caddy-dns/godaddy)
2. 将caddy-dns/godaddy解压后的caddy二进制文件移动到/usr/local/bin/caddy路径中，docker需重新构建镜像
    ```sh
    # Dockerfile-caddy
    FROM caddy:2
    ADD ./caddy_linux_amd64 /usr/local/bin/caddy
    ```
    ```
    docker build -t caddy:2-godaddy -f Dockerfile-caddy .
    ```
### [Caddy with DNS challenge部署](https://github.com/dani-garcia/vaultwarden/wiki/Using-Docker-Compose#caddy-with-dns-challenge)
* vim /opt/vaultwarden/Caddyfile
```json
{$DOMAIN}:443 {
  log {
    level INFO
    output file {$LOG_FILE} {
      roll_size 10MB
      roll_keep 10
    }
  }

  # Use the ACME DNS-01 challenge to get a cert for the configured domain.
  tls {
    dns godaddy {env.GODADDY_TOKEN}
  }

  # This setting may have compatibility issues with some browsers
  # (e.g., attachment downloading on Firefox). Try disabling this
  # if you encounter issues.
  encode gzip

  # Notifications redirected to the WebSocket server
  reverse_proxy /notifications/hub vaultwarden:3012

  # Proxy everything else to Rocket
  reverse_proxy vaultwarden:80
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
      WEBSOCKET_ENABLED: "true"  # Enable WebSocket notifications.
    volumes:
      - ./vw-data:/data

  caddy:
    image: caddy:2-godaddy
    container_name: caddy
    restart: always
    ports:
      - 80:80
      - 443:443
    volumes:
      #- ./caddy:/usr/bin/caddy  # Your custom build of Caddy.
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy-config:/config
      - ./caddy-data:/data
    environment:
      DOMAIN: "https://vaultwarden.example.com"  # Your domain.
      EMAIL: "admin@example.com"                 # The email address to use for ACME registration.
      GODADDY_TOKEN: "<token>"                   # Your godaddy DNS token.
      LOG_FILE: "/data/access.log"
```



# [配置](https://github.com/dani-garcia/vaultwarden/wiki/Configuration-overview)
>第一次在管理页面中保存设置时，config.json将在您的DATA目录中. 此文件中的值将优先于相应的环境变量
```sh
# 禁止新用户注册
SIGNUPS_ALLOWED=false
# 禁止邀请用户加入组织
INVITATIONS_ALLOWED=false
# 启用管理页面(该页面允许服务器管理员查看所有注册用户并删除它们。它还允许邀请新用户，即使在禁用注册时也是如此。强烈建议在启用此功能之前激活 HTTPS，以避免可能的 MITM 攻击)
ADMIN_TOKEN=l8FOfRwtcxPEpRYSUjwblerUt8dU6b/DfR4Z71pNnkoF4xPeZEzCstgV3uN/UMDS   #openssl rand -base64 48 ,生成48位token 对这个令牌保密，这是访问服务器管理区域/admin的密码
# 启用 WebSocket 通知(Bitwarden 客户端与 Bitwarden 服务器（在本例中为 vaultwarden）建立持久的 WebSocket 连接。每当服务器有事件要报告时，它都会通过此持久连接将其发送给客户端)
WEBSOCKET_ENABLED=true  #需要映射WebSocket 服务器端品，-p 3012:3012
# 更改 API 请求大小限制，默认情况下，API 调用限制为 10MB
ROCKET_LIMITS={json=10485760}
# 修改workers数，提升处理能力（docker镜像中默认为10）
ROCKET_WORKERS=20

# 将 vaultwarden 配置为通过 SMTP 代理发送电子邮件
SMTP_HOST=<smtp.domain.tld>
SMTP_FROM=<vaultwarden@domain.tld>
SMTP_PORT=587
SMTP_SECURITY=starttls
SMTP_USERNAME=<username>
SMTP_PASSWORD=<password>
```


