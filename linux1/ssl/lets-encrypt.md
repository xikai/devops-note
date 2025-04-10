* https://letsencrypt.org/zh-cn/
>Let’s Encrypt 是一家全球性的证书颁发机构（CA）， 为世界各地的个人和团体提供获取、续期、管理 SSL/TLS 证书的服务。Let’s Encrypt 提供域名验证型（DV）证书。 但不提供组织验证（OV）或扩展验证（EV），这主要是因为Let’s Encrypt无法自动化地颁发这些类型的证书。

# [深入了解 TLS/SSL 与 PKI](https://www.feistyduck.com/library/bulletproof-tls-guide/online/)
 - https://letsencrypt.org/zh-cn/docs/glossary/
 - ACME (自动证书管理环境 - Automatic Certificate Management Environment) : 由 Let’s Encrypt 实现的协议。 与该协议兼容的软件可以用它与 Let’s Encrypt 通信以获取证书
 - [ACME 客户端 (ACME Client)](https://letsencrypt.org/zh-cn/docs/client-options/) : 能够与 ACME 服务器通信以获取证书的程序。
 - ACME 服务器 (ACME Server) : 与 ACME 协议兼容的能生成证书的服务器。Let’s Encrypt 开发的软件 Boulder 与 ACME 协议兼容，但有一些差异
 
 - 证书颁发机构 (CA - Certificate Authority) : 颁发证书的组织。 Let’s Encrypt、IdenTrust、Sectigo 和 DigiCert 都是证书颁发机构。
 - 证书签名请求 (CSR - Certificate Signing Request) : 包含了 CA 生成证书时所需信息的经过签名的文件。 Let’s Encrypt需要的信息有通用名称、主体备用名称以及主体公钥信息。 通常，客户端应用程序会自动为用户生成 CSR，Web 托管提供商或相关设备也可能会生成 CSR。

# [工作原理](https://letsencrypt.org/zh-cn/how-it-works/)
### 域名所有权验证
1. Webserver Admin Software  ->  Let’s Encrypt ,证书管理软件首次与 Let’s Encrypt 交互时，会<font color=red>生成新的密钥对</font>，并向 Let’s Encrypt CA 证明服务器控制着一个或多个域名。
   - 在 example.com 下配置 DNS 记录（需要ACME客户端支持DNS challenge）
   - 在 https://example.com/ 的已知 URI 下放置一个 HTTP 资源（需要被Let’s Encrypt服务器通过公网访问到）

2. Let’s Encrypt CA 还会提供一个一次性的数字 nonce，管理软件需要用私钥予以签名，从而证明密钥确实属于该软件。完成这些步骤后，证书管理软件会通知 CA 它已准备好完成验证
3. CA 会验证 nonce 的签名，并尝试从 Web 服务器下载指定文件，确认内容准确无误。如果 nonce 的签名有效，验证也顺利通过，那么该公钥对应的证书管理软件就有权管理 example.com 的数字证书。 证书管理软件使用的密钥称为 example.com 的“授权密钥”。

### 证书颁发
>管理软件具备授权密钥后，证书的申请、续期、吊销操作就简单了，只需将各类证书管理指令用授权密钥签名后发给 CA 即可
1. 为了获得该域名的证书，证书管理软件将创建一个 PKCS#10  证书签名请求（CSR），要求 Let’s Encrypt CA 为指定的公钥颁发 example.com 的证书。 CSR 本身已经由其私钥进行了一次签名， 而证书管理软件还会用 example.com 的授权密钥对整个 CSR 再进行一次签名，以便 Let’s Encrypt CA 验证其来源。
2. Let’s Encrypt CA 收到请求后对这两份签名进行验证， 如果全部通过，就为 CSR 中的公钥颁发 example.com 的证书，并将证书文件发给管理软件。

### 证书吊销
* 申请吊销证书的流程类似。 证书管理软件使用 example.com 的授权私钥签署一个吊销请求，Let’s Encrypt CA 将验证该请求是否已被授权。 如果已授权，则将吊销信息发布到正常的吊销通道（即 OCSP）中，以便浏览器等依赖方知道他们不应该接受这个已被吊销的证书

# ACME 客户端 
>实现了 acme 协议, 可以从 letsencrypt 生成免费的证书.
* [Certbot](https://certbot.eff.org/)
* [acme.sh](https://github.com/acmesh-official/acme.sh/wiki/%E8%AF%B4%E6%98%8E)
* [caddy](https://caddyserver.com/docs/automatic-https) Caddy是第一个也是唯一一个自动默认使用HTTPS的web服务器,自动HTTPS为您的所有站点提供TLS证书，并保持更新，它还为您重定向HTTP到HTTPS !
