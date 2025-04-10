* https://www.jianshu.com/p/12e20bf900e1

```
Proto : 自然只的是协议类型
Recv-Q : 远端发来的还未被本机应用层接收的数据大小
Send-Q : 本机应用层发送的还未被对方ACK的数据大小
Local Address : 本地套接字
Foreign Adress : 远端套接字
State : 连接的状态
** ESTABLISHED:连接已建立，三次握手完成
** SYN_SENT:连接发起的主动方，发送SYN包后的状态
** SYN_RECV:连接发起的被动放，收到SYN包后，回复SYN,ACK包后的状态
** FIN_WAIT1:主动断开方，发送FIN包后的状态
** CLOSE_WAIT:收到FIN包后的一方，回复ACK给对方后的状态
** FIN_WAIT2:主动断开方，收到对方回复的ACK包后的状态
** TIME_WAIT:主动断开方，收到对方FIN包的状态
** LAST_ACK:被动断开方无需在传递数据，发送FIN包后的状态
** TIME_WAIT:主动断开方收到对方FIN包后，给出ACK后状态，等待2MSL后进入CLOSING
** CLOSE:该连接已经断开
** LISTEN:监听套接字，被动放调用listen函数后的状态
PID/Program name : 该连接隶属于的进程名及其进程号
```