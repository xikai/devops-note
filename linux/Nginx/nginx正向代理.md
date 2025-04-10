# 配置nginx正向代理服务器
```
server {
    listen 8090;	
    location / {
        resolver 8.8.8.8;
        resolver_timeout 30s;
        proxy_pass $scheme://$host$request_uri;
    }
}

```
# 测试
* 不能代理https
```
# curl -I --proxy http://172.16.0.223:8090 https://www.google.com
HTTP/1.1 400 Bad Request
Server: nginx/1.20.1
Date: Tue, 31 May 2022 13:57:28 GMT
Content-Type: text/html
Content-Length: 157
Connection: close

curl: (56) Received HTTP code 400 from proxy after CONNECT
```
```
# curl -I --proxy http://172.16.0.223:8090 http://www.google.com
HTTP/1.1 200 OK
Server: nginx/1.20.1
Date: Tue, 31 May 2022 13:57:33 GMT
Content-Type: text/html; charset=ISO-8859-1
Connection: keep-alive
P3P: CP="This is not a P3P policy! See g.co/p3phelp for more info."
X-XSS-Protection: 0
X-Frame-Options: SAMEORIGIN
Expires: Tue, 31 May 2022 13:56:53 GMT
Cache-Control: private
Set-Cookie: 1P_JAR=2022-05-31-13; expires=Thu, 30-Jun-2022 13:56:53 GMT; path=/; domain=.google.com; Secure
Set-Cookie: AEC=AakniGMqP_O6gBl8WHhqyLwKWhB9NcioSmgHFK4TzNd1NdK7bdSVTTkLdvs; expires=Sun, 27-Nov-2022 13:56:53 GMT; path=/; domain=.google.com; Secure; HttpOnly; SameSite=lax
Set-Cookie: NID=511=XYkCGNhfDFZ9qJUtWmBwm_isQznZiRqXELqVP4SB7qwOQE_Qo0ul42sdGCLVmMHb85PpD4cqYJv0v5IefqT-uqTBZAKWkZ8OtdLc4Q3IG3nxDdKUW3AGSVJcpSWL2UzQ-eEEM_A-3Syook_flzSjTVH7QCBqCdNvmIzZGkkxNrE; expires=Wed, 30-Nov-2022 13:56:53 GMT; path=/; domain=.google.com; HttpOnly
```

# 系统配置
* vim /etc/profile
```
# export http_proxy=http://username:password@proxyserver:port
export http_proxy=http://nginx_ip:8090
export https_proxy=http://nginx_ip:8090
```