* https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/nodelocaldns/
* https://help.aliyun.com/zh/ack/ack-managed-and-ack-dedicated/user-guide/configure-nodelocal-dnscache
* https://lework.github.io/2020/11/09/node-local-dns/

# 部署NodeLocal DNSCache
```
kubedns=`kubectl get svc kube-dns -n kube-system -o jsonpath={.spec.clusterIP}`
domain="cluster.local" 
localdns="169.254.20.10"    #localdns是 NodeLocal DNSCache 选择的本地侦听 IP 地址。默认为169.254.20.10
```
```
#查询kube-proxy模式(mode) userspace 是iptables 或 ipvs
#kubectl get cm kube-proxy-config -n kube-system -oyaml
```
```
#mode: iptables
sed -i "s/__PILLAR__LOCAL__DNS__/$localdns/g; s/__PILLAR__DNS__DOMAIN__/$domain/g; s/__PILLAR__DNS__SERVER__/$kubedns/g" nodelocaldns.yaml
#mode: ipvs
#sed -i "s/__PILLAR__LOCAL__DNS__/$localdns/g; s/__PILLAR__DNS__DOMAIN__/$domain/g; s/,__PILLAR__DNS__SERVER__//g; s/__PILLAR__CLUSTER__DNS__/$kubedns/g" nodelocaldns.yaml
```

* 部署node-local-dns
>需要注意的是这里使用 DaemonSet 部署 node-local-dns 使用了 hostNetwork=true，会占用宿主机的 8080 端口，所以需要保证该端口未被占用
```
# 国内镜像: kubesphere/k8s-dns-node-cache:1.22.20
kubectl apply -f nodelocaldns.yaml 
```

# 在应用中使用NodeLocal DNSCache
>为了能使应用原本请求CoreDNS的流量改为由DNS缓存DaemonSet代理，需要使Pod内部的中nameservers配置成169.254.20.10和kube-dns对应的IP地址
### 方式一：DNSConfig动态注入控制器Deployment，基于Admission Webhook机制拦截Pod创建的请求，自动注入使用DNS缓存的Pod DNSConfig信息(需要集群具备adminssion webhook功能，或者可以使用第三方的一些插件完成部署)
* 给接入NodeLocal DNSCache的应用所在的命名空间（default）设置标签
  >Admission Controller会忽略kube-system和kube-public命名空间下的应用，请勿在这两个命名空间下进行自动注入dnsConfig操作。
```
kubectl label namespace default node-local-dns-injection=enabled  
```
* 创建新pod,(test-node-local-dns.yaml)
```yml
apiVersion: v1
kind: Pod
metadata:
  name: test-node-local-dns
spec:
  containers:
  - name: local-dns
    #image: busybox:glibc
    image: docker.m.daocloud.io/library/busybox:glibc
    command: ["/bin/sh", "-c", "sleep 60m"]
```
* 开启自动注入后，您创建的Pod会被增加以下字段
```yml
dnsConfig:
  nameservers:
  - 169.254.20.10
  - 172.18.16.10
  options:
  - name: ndots
    value: "3"
  - name: attempts
    value: "2"
  - name: timeout
    value: "1"
  searches:
  - default.svc.cluster.local
  - svc.cluster.local
  - cluster.local
dnsPolicy: None
```

### 方式二：手动指定DNSConfig
>高可用：增加一个备用nameserver，也就是我们的 kube-dns的 clusterIP，从而在 node-local-dns 不可用的情况下，能使用集群中的dns服务
```yml
apiVersion: v1
kind: Pod
metadata:
  name: test-node-local-dns
spec:
  containers:
  - name: local-dns
    #image: busybox:glibc
    image: docker.m.daocloud.io/library/busybox:glibc
    command: ["/bin/sh", "-c", "sleep 60m"]
  dnsPolicy: None
  dnsConfig:
    nameservers: ["169.254.20.10","172.18.16.10"]
    searches:
    - default.svc.cluster.local
    - svc.cluster.local
    - cluster.local
    options:
    - name: ndots
      value: "3"
    - name: attempts
      value: "2"
    - name: timeout 
      value: "1"
```
>上述命令仅会开启default命名空间的自动注入，如需对其他命名空间开启自动注入，则需要替换default为目标命名空间名称


# 验证
* 待 pod 启动后，查看 /etc/resolv.conf
```
$ k exec -it test-node-local-dns -- cat /etc/resolv.conf       
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 169.254.20.10
nameserver 172.18.16.10
options ndots:3 attempts:2 timeout:1
```
> 如果一个域名中包含的点的数量少于 ndots 值，那么这个域名会被认为是相对域名，会在本地域名搜索列表中进行搜索。如果域名中包含的点的数量等于或多于 ndots 值，那么这个域名会被认为是fqdn完全合格域名，直接进行解析,域名中的点（.）数目等于或大于设置的值时，也会只查询一次。适当降低 ndots 值有利于加速集群外部域名访问。
```
本地缓存：你的 DNS 解析器或 Kubernetes 环境可能会有缓存。如果 baidu.com 已经在缓存中，解析器会直接返回缓存结果而不进行进一步的搜索域追加。

超时和尝试次数：DNS 配置中的 attempts 和 timeout 选项也会影响解析行为。由于你的 attempts 设置为 2 和 timeout 设置为 1，解析器可能在第一次尝试中成功解析了 baidu.com，所以没有进行进一步的搜索域追加
```

* 解析外部域名
```sh
$ k exec -it test-node-local-dns -- nslookup -type=a www.baidu.com
Server:         169.254.20.10
Address:        169.254.20.10:53

Non-authoritative answer:
www.baidu.com   canonical name = www.a.shifen.com
Name:   www.a.shifen.com
Address: 39.156.66.14
Name:   www.a.shifen.com
Address: 39.156.66.18
```

* 解析k8s完整内部域名
```sh
$ k exec -it test-node-local-dns -- nslookup -type=a kubernetes.default.svc.cluster.local
Server:         169.254.20.10
Address:        169.254.20.10:53

Name:   kubernetes.default.svc.cluster.local
Address: 172.18.16.1
```

* 解析k8s svc内部域名
```sh
$ k exec -it test-node-local-dns -- nslookup -type=a kubernetes
Server:         169.254.20.10
Address:        169.254.20.10:53

** server can't find kubernetes.cluster.local: NXDOMAIN

Name:   kubernetes.default.svc.cluster.local
Address: 172.18.16.1

** server can't find kubernetes.svc.cluster.local: NXDOMAIN

command terminated with exit code 1
```

# 高可用验证
* 删除node-local-dns
```sh
k delete ds node-local-dns -n kube-system
```
* 再次解析响应的nameserver变为172.18.16.10(kube-dns),但会出现5秒延迟bug
```sh
$ k exec -it test-node-local-dns -- nslookup -type=a www.baidu.com                       
Server:         172.18.16.10
Address:        172.18.16.10:53

Non-authoritative answer:
www.baidu.com   canonical name = www.a.shifen.com
Name:   www.a.shifen.com
Address: 39.156.66.18
Name:   www.a.shifen.com
Address: 39.156.66.14
```
```sh
$ k exec -it test-node-local-dns -- nslookup -type=a kubernetes.default.svc.cluster.local
Server:         172.18.16.10
Address:        172.18.16.10:53

Name:   kubernetes.default.svc.cluster.local
Address: 172.18.16.1
```
```sh
$ k exec -it test-node-local-dns -- nslookup -type=a kubernetes   
Server:         172.18.16.10
Address:        172.18.16.10:53

** server can't find kubernetes.cluster.local: NXDOMAIN

Name:   kubernetes.default.svc.cluster.local
Address: 172.18.16.1

** server can't find kubernetes.svc.cluster.local: NXDOMAIN

command terminated with exit code 1
```