* https://www.cnblogs.com/kerwincui/p/14179837.html
* https://zhuanlan.zhihu.com/p/371891073
* https://www.ssl.com/zh-CN/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98/%E4%BB%80%E4%B9%88%E6%98%AF%E8%AF%81%E4%B9%A6%E9%A2%81%E5%8F%91%E6%9C%BA%E6%9E%84/

# 数字证书
>数字证书是一个经权威授权机构数字签名，包含公开密钥的拥有者信息以及公开密钥的文件，是权威机构颁发给网站的可信凭证。最简单的证书包含一个公开密钥、证书名称以及证书授权中心的数字签名。数字证书的一个重要特征：只在特定的时间段内有效。

### CA认证机构
> CA认证机构，即证书授权中心（Certificate Authority）或称证书颁发机构。
> CA认证机构作为电子商务交易中受信任的第三方，承担公钥体系中公钥合法性检验的责任。


* 数字证书申请过程一般为：
  1. 服务方生成自己的公钥和私钥。将公钥及部分个人身份信息传送给CA认证机构。
  2. CA认证机构在核实身份后，将执行一些必要的步骤，以确信请求确实由服务提供者发送而来，
  3. 验证通过后，CA认证机构将发给服务提供者数字证书，该证书内包含证书申请者(服务方)的信息和他的公钥信息，同时还附有CA认证机构的签名信息

* 颁发的证书文件
  * 证书文件（Certificate file）：该文件包含了证书的公钥和相关信息，例如证书颁发机构、域名、有效期等。证书文件通常是以 PEM、DER 或 PFX 格式存储
  * 私钥文件（Private key file）：该文件包含了证书的私钥，是保证通信安全的重要部分。私钥文件通常是以 PEM、DER 或 PFX 格式存储。

* CA根证书(ca.crt/ca.pem/ca.der等格式)：是CA认证中心给自己颁发的证书,是信任链的起始点。安装根证书意味着对这个CA认证机构的信任。
### 证书信任链
* 证书直接是可以有信任关系的, 通过一个证书可以证明另一个证书也是真实可信的。假设 C证书信任 A 和 B；然后 A 信任 A1 和 A2；B 信任 B1 和 B2。只要你信任链上的头一个证书C，那后续的证书，都是可以信任的

### 证书标准规范X.509
* 证书是由认证机构颁发的，使用者需要对证书进行验证，因此如果证书的格式千奇百怪那就不方便了。于是，人们制定了证书的标准规范，其中使用最广泛的是ISO（IntemationalOrganizationforStandardization, 国际标准化组织）制定的X.509规范。很多应用程序都支持x.509并将其作为证书生成和交换的标准规范。其中定义了如下证书信息域：
```
* 版本号(Version Number）：规范的版本号，目前为版本3，值为0x2；
* 序列号（Serial Number）：由CA维护的为它所发的每个证书分配的一的列号，用来追踪和撤销证书。只要拥有签发者信息和序列号，就可以唯一标识一个证书，最大不能过20个字节；
* 签名算法（Signature Algorithm）：数字签名所采用的算法，如：
    sha256-with-RSA-Encryption
    ccdsa-with-SHA2S6；
* 颁发者（Issuer）：发证书单位的标识信息，如 ” C=CN，ST=Beijing, L=Beijing, O=org.example.com，CN=ca.org。example.com ”；
* 有效期(Validity): 证书的有效期很，包括起止时间。
* 主体(Subject) : 证书拥有者的标识信息（Distinguished Name），如：" C=CN，ST=Beijing, L=Beijing, CN=person.org.example.com”；

* 主体的公钥信息(SubJect Public Key Info）：所保护的公钥相关的信息：
    公钥算法 (Public Key Algorithm）公钥采用的算法；
    主体公钥（Subject Unique Identifier）：公钥的内容。
* 颁发者唯一号（Issuer Unique Identifier）：代表颁发者的唯一信息，仅2、3版本支持，可选；

* 主体唯一号（Subject Unique Identifier）：代表拥有证书实体的唯一信息，仅2，3版本支持，可选：
* 扩展（Extensions，可选）: 可选的一些扩展。中可能包括：
    Subject Key Identifier：实体的秘钥标识符，区分实体的多对秘钥；
    Basic Constraints：一指明是否属于CA;
    Authority Key Identifier：证书颁发者的公钥标识符；
    CRL Distribution Points: 撤销文件的颁发地址；
    Key Usage：证书的用途或功能信息。
此外，证书的颁发者还需要对证书内容利用自己的私钥添加签名， 以防止别人对证书的内容进行篡改。
```
```
X.509 DER(Distinguished Encoding Rules)编码，后缀为：.der .cer .crt
X.509 BASE64编码(PEM格式)，后缀为：.pem .cer .crt
```

### SSL/TLS证书
>SSL证书是数字证书的一种,SSL协议是一种可实现网络通信加密的安全协议，可在浏览器和网站之间建立加密通道，保障数据在传输的过程中不被篡改或窃取。SSL（Secure Socket Layer，安全套接字层），TLS（Transport Layer Security，传输层安全协议）
* ssl证书类型
  - DV（域名型）- 适用网站类型:个人网站,公信等级:一般,认证强度:CA机构审核个人网站真实性、不验证企业真实性
  - OV（企业型）- 适用网站类型:政府组织、企业、教育机构等,公信等级:高,认证强度:CA机构审核组织及企业真实性
  - EV（企业增强型）-	适用网站类型:大型企业、金融机构等,公信等级:最高,认证强度:严格认证