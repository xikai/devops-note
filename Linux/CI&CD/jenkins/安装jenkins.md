```
# 将容器中的 /var/jenkins_home 目录映射到 Docker volume ，并将其命名为 jenkins-data
docker run \
  -u root \
  -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /data/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkinsci/blueocean
```
```
# 首次启动可能会遇到页面一直显示"Please wait while Jenkins is getting ready to work ..."
# 该Jenkins实例似乎已离线

修改/var/jenkins_home/hudson.model.UpdateCenter.xml
该文件为jenkins下载插件的源地址，该地址默认为：https://updates.jenkins.io/update-center.json，就是因为https的问题，此处我们将其改为http即可，之后重启jenkins服务即可。
其他国内备用地址（也可以选择使用）：
http://mirror.xmission.com/jenkins/updates/update-center.json
https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json

# 更改default.json中的url
vim jenkins/updates/default.json
把 "connectionCheckUrl":"http://www.google.com/" 改为  "connectionCheckUrl":"http://www.baidu.com/"

sed -i 's@http://updates.jenkins-ci.org/download/@https://mirrors.tuna.tsinghua.edu.cn/jenkins/@g' default.json
```

```
# 检查DNS解析，/etc/resolv.conf
# 检查容器是否能上外网
# 检查net.ipv4.ip_forward = 1是否开启转发
```


