### SMTP
* 发邮件：smtplib
  * 内置模块
  * smtplib.SMTP(host=,port,)
    * 连接邮件服务器
    * host：邮件服务器主机
    * port：邮件服务器端口
 
  * smtp = smtplib.SMTP_SSL(host='',port='')
  * smtp.connect(host,port)
  * smtp.login(user,passwd)
    * user：邮件登录用户名
    * passwd：邮件服务器登录密码
  * smtp.quit()
    * 断开与邮件服务器的连接
 
  * POP3/SMTP ： ycuxpvatjculbdci
  * IMAP/SMTP ： pgfhvulbsfembcbb 
    * SMTP：发邮件用的协议
    * POP3：接收邮件
    * IMAP：接收邮件
      * 会保留邮件，
 
  * QQ邮箱邮件地址：smtp.qq.com

    ```python
    import smtplib
    host = 'smtp.qq.com'
    port = 465
    user = '794250774@qq.com'
    passwd_pop3 = 'ycuxpvatjculbdci'
    #passwd_imap = 'pgfhvulbsfembcbb'
    to_user = ['2573799357@qq.com','99263007@qq.com','1549378418@qq.com','1321842251@qq.com']
    email_data = '这是个测试'
     
    smtp =smtplib.SMTP_SSL(host,port) #连接并初始化smtp对象
    smtp.login(user,passwd_pop3) #登录smtp服务器
    for to in to_user: #发送邮件，遍历用户
        msg = 'From:%s\r\n' % user+ \
              'To:%s\r\n' % to + \
              'Subject:%s\r\n' % '哈哈哈' + \
              '\r\n' + \
              email_data
        smtp.sendmail(user,to,msg.encode('utf-8'))
    ```
 
* 花哨邮件发送：
  * MIME类型：多用途网络邮件扩展类型
    * Content-Type：
      * text/plain
      * text/html
  * email.mime.text.MIMEText(text,subtype,charset)
    * text发送的邮件html内容
    * subtype
      * plain：文本格式发送
      * html：html格式
    * charset：编码
  * from email.mime.image import MIMEImage(image_data,subtype)
    * image_data:图像二进制内容
    * img_.add_header('Content-ID','image')
  * from email.mime.multipart import MIMEMultipart(subtype)
    * multipart/mixed：可以包含纯文本，超文本，内嵌资源
    * multipart/related：包含内嵌资源
    * multipart/alternative：包含纯文本plain，超文本html
    * MIMEMultipart.attac(MIMETYPE)  
  * 构造具有附件的邮件，附件体的编码格式为base64
    * 邮件的传输格式也要改为application/octet-stream
    
* 发HTML邮件
  ```python
    from email.mime.text import MIMEText
    import smtplib
    host = 'smtp.qq.com'
    port = 465
    user = '794250774@qq.com'
    passwd_pop3 = 'ycuxpvatjculbdci'
    #passwd_imap = 'pgfhvulbsfembcbb'
    to_user = ['2573799357@qq.com','99263007@qq.com','1549378418@qq.com','1321842251@qq.com']
    email_data = '<a href="https://www.baidu.com"> 哈哈哈哈 </a>'
     
    smtp =smtplib.SMTP_SSL(host,port) #连接并初始化smtp对象
    smtp.login(user,passwd_pop3) #登录smtp服务器
     
    html_eamil_data = MIMEText(email_data,'html','utf-8')
    html_eamil_data['From'] = user
    html_eamil_data['Subject'] = 'HTML邮件测试'
     
    for to in to_user:
        html_eamil_data['To'] = to
        smtp.sendmail(user,to,html_eamil_data.as_string())
    smtp.quit()
  ```
  
* 发带静态资源的HTML邮件
    ```python
    from email.mime.text import MIMEText
    from email.mime.image import MIMEImage
    from email.mime.multipart import MIMEMultipart
    import smtplib
    host = 'smtp.qq.com'
    port = 465
    user = '794250774@qq.com'
    passwd_pop3 = 'ycuxpvatjculbdci'
    #passwd_imap = 'pgfhvulbsfembcbb'
    to_user = [
        '2573799357@qq.com',
        '99263007@qq.com',
        '1549378418@qq.com',
    ]
    email_data = '<a href="https://www.baidu.com"> 哈哈哈哈 </a>'
    smtp =smtplib.SMTP_SSL(host,port) #连接并初始化smtp对象
    smtp.login(user,passwd_pop3) #登录smtp服务器
     
     
    with open('image.jpg','rb') as fp:
        image_data = fp.read()
    content = """
        <div>这是一个图片测试</div>
        <img src="cid:image">
    """ #构造HTML字符串
    con_ = MIMEText(content,'html','utf-8') #图片和要HTML组合，不是和一个字符串组合
     
    #构建图片MIME类型
    img_ = MIMEImage(image_data)
    img_.add_header('Content-ID','image') #替换这张图片到HTML邮件体中的位置
    #组合
    msg = MIMEMultipart('mixed') #创建了一个空壳
    msg.attach(con_) #先放入html
    msg.attach(img_) #再放入图片
     
    msg['From'] = user
    msg['Subject'] = '美女图片测试'
     
    for to in to_user:
        msg['To'] = to
        smtp.sendmail(user,to,msg.as_string())
    smtp.quit()
    ```

* 发送带附件邮件
    ```python
    from email.mime.text import MIMEText
    from email.mime.image import MIMEImage
    from email.mime.multipart import MIMEMultipart
    import smtplib
    host = 'smtp.qq.com'
    port = 465
    user = '794250774@qq.com'
    passwd_pop3 = 'ycuxpvatjculbdci'
    #passwd_imap = 'pgfhvulbsfembcbb'
    to_user = [
        '2573799357@qq.com',
        '99263007@qq.com',
        '1549378418@qq.com',
    ]
    email_data = '<a href="https://www.baidu.com"> 哈哈哈哈 </a>'
    smtp =smtplib.SMTP_SSL(host,port) #连接并初始化smtp对象
    smtp.login(user,passwd_pop3) #登录smtp服务器
     
    content = """
        <h1>具有附件的邮件测试</h1>
    """
    msg = MIMEText(content,'html','utf-8')
     
    with open('附件.jpg','rb') as fp:
        img_data = fp.read()
     
    img = MIMEText(img_data,'base64','utf-8') #base64：传输
    img['Content-Type'] = 'application/octet-stream' #指明当前传输是二进制
    img['Content-Disposition'] = 'attachment; filename="girl.jpg"' #附件名
    #application/octet-stream  #二进制数据
     
    箩筐= MIMEMultipart('mixed')
    箩筐.attach(msg)
    箩筐.attach(img)
    箩筐['From'] = user
    箩筐['Subject'] = '附件测试'
     
    for to in to_user:
        箩筐['To'] = to
        smtp.sendmail(user,to,箩筐.as_string())
    smtp.quit()
    ```