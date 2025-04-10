>https://docs.gitlab.com/omnibus/docker/
* 安装gitlab
```
docker run --detach \
  --hostname gitlab.dadi01.com \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab-ee \
  --restart always \
  --volume /srv/gitlab/config:/etc/gitlab \
  --volume /srv/gitlab/logs:/var/log/gitlab \
  --volume /srv/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ee:latest
```

* 配置gitlab
>vim /srv/gitlab/config/gitlab.rb
```
# note the 'https' below
external_url 'https://gitlab.dadi01.com/'

gitlab_rails['gitlab_shell_ssh_port'] = 28
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/ssl/dadi01.com.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/dadi01.com.key"
nginx['ssl_client_certificate'] = "/etc/gitlab/ssl/dadi01.com.ca"
nginx['ssl_verify_client'] = "off"

gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.exmail.qq.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "giltlab_8@dadi01.com"
gitlab_rails['smtp_password'] = "8fePkvFe7Ck7KfLb"
gitlab_rails['smtp_domain'] = "smtp.exmail.qq.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
gitlab_rails['gitlab_email_from'] = 'gitlab_8@dadi01.com'
```
```
docker restart gitlab-ee
```

* 备份
>https://docs.gitlab.com/omnibus/settings/backups.html \
https://docs.gitlab.com/ce/raketasks/backup_restore.html#restore-for-omnibus-installations
```
#备份数据
docker exec -t <your container name> gitlab-rake gitlab:backup:create
#备份配置
docker exec -t <your container name> /bin/sh -c 'umask 0077; tar cfz /var/opt/gitlab/backups/$(date "+etc-gitlab-%s-%Y%m%d.tgz") -C / etc/gitlab'
```

* 恢复
```
#docker和helm安装的gitlab，还原备份时确保容器/var/opt/gitlab/backups为空 不存在lost+found目录
docker exec -it <name of container> gitlab-rake gitlab:backup:restore
```