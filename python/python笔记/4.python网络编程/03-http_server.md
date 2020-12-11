```python
import socket
 
s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
#IPV4 , TCP协议的套接字
s.bind(('',80))
s.listen(5)
'''
GET / HTTP/1.1\r\n
Host: 127.0.0.1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:61.0) Gecko/20100101 Firefox/61.0\r\n
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n
Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2\r\n
Accept-Encoding: gzip, deflate\r\n
Cookie: test="hello cookie"\r\n
Connection: keep-alive\r\n
Upgrade-Insecure-Requests: 1\r\n
'''
with open('index.html') as fp:
    html = fp.read() 
with open('1.jpg','rb') as fp:
    img = fp.read()
while 1:
    c,c_addr = s.accept()
    httpRequest = c.recv(1024).decode()
    #接收访问者发来的httpRequest请求
    request_way = httpRequest.split('\r\n')[0].split(' ')[0]
    request_url = httpRequest.split('\r\n')[0].split(' ')[1]
    print('------------------')
    rt = [ buf.split(':') for buf in httpRequest.split('\r\n')[1:] if buf]
    request = {}
    for var in rt:
        key = var[0].strip()
        value = var[1].strip()
        request[key] = value
    print(httpRequest)
    user_agent = httpRequest.split()
    if request_way == 'GET':
        if request_url == '/':
            msg = 'HTTP/1.1 200 OK\r\n' + \
                  'Server: Niu\r\n' + \
                  'Content-Type: text/html; charset=utf-8\r\n' + \
                  'Content-Length: %s' % len(html) + \
                  '\r\n' + \
                  html
            c.send(msg.encode())
 
        elif request_url == '/1.jpg':
            headers = 'HTTP/1.1 200 OK\r\n' + \
                  'Server: Niu\r\n' + \
                  'Content-Type: image/mpeg\r\n' + \
                  '\r\n'
                   
            #headers + body
            c.send(headers.encode()+img)
 
    c.close()
```