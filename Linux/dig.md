* https://cloud.tencent.com/developer/article/2018521
* https://www.sysgeek.cn/linux-dig/
* https://blog.csdn.net/u014029795/article/details/87226813
* https://www.jianshu.com/p/62a9f68a2573

# 指定DNS服务器查询域名解析（不指定DNS服务器时dig 将尝试 /etc/resolv.conf 中列举的任何服务器）
```
dig www.examples.com @dns_server
```

# +short简短查询
```
dig www.sysgeek.cn +short
```

# dig 命令的输出：
* 第一行会打印出已安装的 dig 版本，以及查询的域名；第二行显示全局选项（默认情况下，仅有 cmd）
```
; <<>> DiG 9.10.6 <<>> www.vevor.es @ns62.domaincontrol.com
;; global options: +cmd
```
* 本节输出包括从被请求机构（DNS 服务器）收到响应的详细技术信息。标题显示由 dig 执行操作的「操作码」和「操作状态」的「标头」，上述示例中的「操作状态」是NOERROR，这意味着被请求的 DNS 服务器可没有任何阻碍地提供查询。可以用+comments参数隐藏本节输出
```
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 52080
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available
```
* 「OPT」伪装部分仅在较新版本的 dig 工具中显示。要隐藏此部分输出可以使用+noedns参数
```
;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1472
```
* 在「QUESTION」部分输出会显示 dig 将要查询的内容，默认情况下 dig 会查询 A 记录。 可以使用+noquestion参数禁用此部分输出。
```
;; QUESTION SECTION:
;www.vevor.es.			IN	A
```
* ANSWER」部分为我们提供了查询的答案，正如我们已经提到的，默认情况下 dig 将请求 A 记录。可以使用+noanswer参数删除此部分输出
```
;; ANSWER SECTION:
www.vevor.es.		600	IN	CNAME	d2rppkpbg5vd3z.cloudfront.net.
```
* 这是 dig 输出的最后一部分内容，其中包括有关查询的统计信息。可以使用+nostats参数禁用此部分输出
```
;; Query time: 253 msec
;; SERVER: 173.201.69.32#53(173.201.69.32)
;; WHEN: Sat Nov 05 00:55:00 CST 2022
;; MSG SIZE  rcvd: 84
```