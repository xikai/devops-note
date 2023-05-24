* https://dmarc.org/overview/
* http://www.open-spf.org/Project_Overview/

* https://help.aliyun.com/document_detail/44631.html
* https://docs.aws.amazon.com/zh_cn/ses/latest/dg/send-email-authentication-dmarc.html#send-email-authentication-dmarc-dns

# [防止欺骗和垃圾邮件](https://support.google.com/a/answer/2466580?hl=zh-Hans)
>垃圾邮件发送者可以伪造您的域或组织来发送看似来自您的组织的虚假邮件。这称为欺骗。欺骗性消息可用于恶意目的。例如，欺骗性消息可以传播虚假信息、发送有害软件或诱骗人们泄露敏感信息。SPF 允许接收服务器验证看似来自您的域的邮件是真实的，而不是伪造或欺骗的。 为了进一步防止欺骗和其他恶意电子邮件活动，我们建议您还设置 DKIM 和 DMARC。SPF、DKIM 和 DMARC 按域应用。如果您管理多个域，则必须为每个域分别启用 SPF、DKIM 和 DMARC。
* [SPF(Sender Policy Framework),发件人策略框架](https://support.google.com/a/answer/33786):指定授权代表您的组织发送电子邮件的服务器和域
  >要为您的域启用发件人策略框架 (SPF)，请在您的域提供商处添加域名系统 (DNS) TXT 记录,https://support.google.com/a/answer/10685031
  ```
  #SPF 记录示例，用于通过 Google Workspace 和您的其他电子邮件发件人发送电子邮件,域可以有一个 SPF 记录。但是，域的 SPF 记录可以指定允许为该域发送邮件的多个服务器和第三方。
  v=spf1 include:_spf.google.com ~all
  ```
* [DKIM(DomainKeys Identified Mail),域密钥识别邮件](https://support.google.com/a/answer/174124):为每封外发邮件添加数字签名，让接收服务器验证邮件实际上来自您的组织。并且在传输过程中没有被伪造或更改。
  ```
  为您的域启用 DKIM
  第 1 步：在您的管理控制台中获取您的 DKIM 密钥,https://support.google.com/a/answer/180504
  第 2 步：在您的域提供商处添加您的 DKIM 密钥
  第 3 步：在您的管理控制台中启用 DKIM
  第 4 步：验证 DKIM 签名是否开启
  ```
* [DMARC(Domain-based Message Authentication, Reporting, and Conformance),基于域的消息身份验证、报告和一致性协议](https://support.google.com/a/answer/2466580):让您告诉接收服务器如何处理来自您的组织但未通过 SPF 或 DKIM 的传出消息。
  * 设置 DMARC
    1. **为您的域设置 SPF 和 DKIM**, 使用 DMARC 策略要求从您的域发送的邮件由具有 SPF 和 DKIM 的接收服务器进行身份验证。
        * 注意：如果您在启用 DMARC 之前未设置 SPF 和 DKIM，则从您的域发送的邮件可能会出现递送问题。设置 SPF 和 DKIM 后等待 48 小时，然后再设置 DMARC。
    2. **设置报告组或邮箱**：您通过电子邮件收到的 DMARC 报告的数量可能会有所不同，具体取决于您的域发送的电子邮件数量。您每天都可以收到很多报告。大型组织每天可能会收到数百甚至数千份报告。我们建议您创建一个群组或专用邮箱来接收和管理 DMARC 报告。
    3. **检查现有的 DMARC 记录**，[DMARC Check Tool](https://stopemailfraud.proofpoint.com/dmarc/)：在为您的域设置 DMARC 之前，您可以选择检查您的域是否具有现有的 DMARC DNS TXT 记录。默认情况下，邮件提供商和域提供商并不总是打开 DMARC。如果您的域有 DMARC 记录，则有一个 TXT 记录条目以v=DMARC
    4. **确保第三方邮件经过身份验证** ，从您域的第三方电子邮件提供商发送的有效邮件可能无法通过 SPF 或 DKIM 检查。未通过这些检查的邮件将受到 DMARC 政策中定义的操作的约束。他们可能会被发送到垃圾邮件，或被拒绝。为帮助确保第三方提供商发送的消息经过身份验证：
        * 请联系您的第三方提供商以确保 DKIM 设置正确。
        * 确保提供商的信封发件人域与您的域匹配。将提供商发送邮件服务器的 IP 地址添加到您域的 SPF 记录中。
    5. **DMARC 在您的域名托管服务提供商处启用** ，在域名提供商设置中的 DNS TXT 记录中为您的域名启用 DMARC,当来自您域的邮件未通过 DMARC 身份验证时，您的 DMARC 策略向接收邮件服务器建议要采取的操作。
        * [DMARC 政策选项](https://support.google.com/a/answer/10032169)
        * [添加DMARC 记录](https://support.google.com/a/answer/2466563#dmarc-record-tags)
          >如果您不为子域创建 DMARC 策略，它们将继承父域的 DMARC 策略
          ```
          # 在您的域提供商处添加_dmarc.solarmora.com主机的DNS TXT 记录,某些域名托管服务商会自动在 _dmarc 后添加域名，例如您输入 _dmarc.solarmora.com并且您的域名托管服务商自动添加您的域名，则 TXT 记录名称将被错误地格式化为_dmarc.solarmora.com.solarmora.com。
          v=DMARC1; p=reject; rua=mailto:postmaster@solarmora.com, mailto:dmarc@solarmora.com; pct=100; adkim=s; aspf=s
          ```