* https://yeasy.gitbook.io/docker_practice/image/dockerfile/entrypoint

# CMD && ENTRYPOINT
### ENTRYPOINT、CMD同时存在时,CMD作为ENTRYPOINT指定参数
```
ENTRYPOINT ["/bin/echo"] 
CMD ["this is a test"]
docker run -it imageecho 输出"this is a test"（执行/bin/echo "this is a test"）
```

### 覆盖
* docker run的参数会覆盖CMD
```
# demo
FROM ubuntu:trusty
CMD ping localhost
```
```
$ docker run -t demo
PING localhost (127.0.0.1) 56(84) bytes of data.
64 bytes from localhost (127.0.0.1): icmp_seq=1 ttl=64 time=0.051 ms
64 bytes from localhost (127.0.0.1): icmp_seq=2 ttl=64 time=0.038 ms
^C
--- localhost ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.026/0.032/0.039/0.008 ms
```
```
$ docker run demo hostname
6c1573c0d4c0

```
* --entrypoint参数也会覆盖ENTRYPOINT，否则 docker run参数会追加到ENTRYPOINT后面
```
# demo
FROM ubuntu:trusty
ENTRYPOINT ping localhost
```
```
$ docker run --entrypoint hostname demo
075a2fa95ab7
```

### Shell vs. Exec (ENTRYPOINT和CMD指令支持2种不同的写法)
* shell form, 命令作为sh程序的子程序运行
```
ENTRYPOINT ping localhost
CMD ping localhost
```
```
$ docker run -d demo
15bfcddb11b5cde0e230246f45ba6eeb1e6f56edb38a91626ab9c478408cb615

$ docker ps -l
CONTAINER ID IMAGE COMMAND CREATED
15bfcddb4312 demo:latest "/bin/sh -c 'ping localhost'" 2 seconds ago 

# PID为1的进程并不是在Dockerfile里面定义的ping命令, 而是/bin/sh命令
# 如果从外部发送任何POSIX信号到docker容器, 由于/bin/sh命令不会转发消息给实际运行的ping命令, 则不能安全得关闭docker容器
$ docker exec 15bfcddb ps -f
UID PID PPID C STIME TTY TIME CMD
root 1 0 0 20:14 ? 00:00:00 /bin/sh -c ping localhost
root 9 1 0 20:14 ? 00:00:00 ping localhost
root 49 0 0 20:15 ? 00:00:00 ps -f
```
* 在上面的ping的例子中, 如果用了shell形式的CMD, 用户按ctrl-c也不能停止ping命令, 因为ctrl-c的信号没有被转发给ping命令


* exec form
```
FROM busybox
ENTRYPOINT ["/bin/ping"]
CMD ["localhost"]
```
```
# 追加docker run 参数到ENTRYPOINT，并覆盖CMD
$ docker run -t --name demo ping:latest baidu.com
PING baidu.com (220.181.38.148): 56 data bytes
64 bytes from 220.181.38.148: seq=0 ttl=37 time=46.358 ms
64 bytes from 220.181.38.148: seq=1 ttl=37 time=53.020 ms
64 bytes from 220.181.38.148: seq=2 ttl=37 time=44.262 ms
^C
--- baidu.com ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 44.262/47.880/53.020 ms
```