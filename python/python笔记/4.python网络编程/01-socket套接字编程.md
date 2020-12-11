### TCP/UDP
 * TCP用来构成网络连接
 * UDP只管发，不管你究竟收没收到
    * 好处：节省效率
    * 流视频，音频：UDP
 * TCP：打电话
 * UDP：发短信
 
### 套接字编程
* 互联网通信：两者的地址
  * IP:Port
  * 套接字：一个具备IP和端口的对象，就叫套接字
  * 套接字的类型主要有两种：TCP（面向连接）、UDP（无连接）
 
* socket 内置
  * import socket
    * socket.AF_INET：IPV4
    * socket.STREAM：TCP
    * socket.DGRAM：UDP
 
* 创建套接字：
  * 服务器/客户端
  * 先写个服务器：
    * socket.socket(socket_family, socket_type)
      * socket_family：IP地址家族
      * socket_type：套接字类型
 
* -------------
 
#### TCP套接字模型
  * TCP服务器套接字创建模型：
    * s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    * s.bind( ('', 8000) )：绑定该套接字有效地址和端口
      * 参数是一个元组
    * s.listen(5)  开启服务器
    * c,c_addr  = s.accept() 阻塞等待客户端连接
      * c：客户端来访套接字来与客户端进行交流
      * c_addr：客户来访地址，(ip,port)
    * while：具体和这个客户端进行沟通
      * c.send(msg)
        * 发送数据
        * msg == byte
      * data = c.recv(1024)： -> bytes
        * 接收数据
        * 接收到的也是个二进制
      * 取决于客户端发来的数据如果为空，那么就可以关闭与他的连接了。
    * c.close()
      * 关闭套接字 释放资源
    * s.close()
    
    ```python
    import socket
    #s: 等待连接
    #c: 实际通信
    s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    s.bind( ('',25555) )
    s.listen(5)
    print('[+] 服务端开启...')
    while True:
        #死循环接收客户端访问
        try:
            c,c_addr = s.accept()
            #先接受客户端发来的数据
            print('有人来了:',c_addr)
            while True:
                data = c.recv(1024).decode('utf-8')
                if not data: #接收到的数据 是一个None
                    #判断这个客户端究竟还在吗？not None == True
                    print('[+] 这个人走了...')
                    break
                print('这个人说:',data)
                msg = input('>>>')
                if msg == 'quit':
                     print('[+] 与这个人主动断开连接...')
                     break
                c.send(msg.encode('utf-8'))
            c.close()
        except KeyboardInterrupt:
            break
    print('[+] 服务端关闭')
    s.close()
    ```
 
  * TCP客户端套接字模型：
    ```python
    import socket
    #STRAM: TCP
    c = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    c.connect( ('47.104.224.67',25555) )
    print('[+] 连接成功...')
    while True:
        msg = input('>>>')
        if msg == 'quit':
            break
        c.send(msg.encode('utf-8'))
     
        data = c.recv(1024)
        if not data:
            #服务端主动断开
            break
            print('[+] 服务端主动断开了连接...')
        print('服务端发来:',data.decode('utf-8'))
     
    print('[+] 连接关闭...')
    c.close()
    ```
    
* 单进程模型下，我们写的代码，同一时间只能处理一个用户的来访信息
  * TCP是要构成连接的
 
 
#### UDP套接字模型
* UDP不需要构成连接，直接发送即可
* UDP服务端模型：
  * s = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
  * s.bind(('',25555))
    * data,c_addr = s.recvfrom(1024)  
      * 别人发来的消息 就直接发到s服务端套接字了 
      * data：发来的数据
      * c_addr：谁发的
    * s.sendto(msg, c_addr)

  ```python
    import socket
     
    s = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    s.bind(('',25556) )
    print('[+] Server Open...')
    while True:
        try:
            data,c_addr = s.recvfrom(1024) #bytes
            print('[+] from:',c_addr)
            print('$:',data.decode('utf-8'))
            #msg = input('>>>')
            msg = data.decode('utf-8') + '| lee'
            s.sendto(msg.encode('utf-8'),c_addr)
        except KeyboardInterrupt:
            break
    print('[+] Server Closed...')
    s.close()  
  ```
  
* UDP客户端套接字模型：
  ```python
    import socket
    #DGRAM:UDP
    c = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    print('[+] 连接成功')
    while True:
        try:
            msg = input('>>>')
            c.sendto(msg.encode('utf-8'),('47.104.224.67',25555))
            data,s_addr = c.recvfrom(1024)
            print('$:',data.decode('utf-8'))
        except KeyboardInterrupt:
            break
    c.close()
  ```