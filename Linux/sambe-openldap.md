* http://www.cnblogs.com/mchina/archive/2012/12/18/2816717.html
* http://wenku.baidu.com/link?url=Yt3JkT9BrkhVkqCT2hW2Mg8TXc76Mudv4H5nbFIKamWHl732U1FhhLCAH2MEFGOHf4cnvo9D81cyXAVGNE0MMzuZSKfDD8fPhunRqgUgnJa

* 安装samba、openldap
```bash
yum install -y samba samba-client samba-common samba-swat
yum install -y openldap openldap-clients nss-pam-ldapd pam_ldap

mkdir -p /samba/{public,hr}
chmod -R 777 /samba
```

* 将ldap samba模块传输到ldap服务器
```bash
scp /usr/share/doc/samba-3.6.23/LDAP/samba.schema root@192.168.60.65:/etc/openldap/schema
```

* ldapserver 添加samba模块 
```bash
vim /etc/openldap/slapd.conf
添加：
include         /etc/openldap/schema/samba.schema

service slapd restart
```

* 将ldap用户加入系统用户认证
```
setup
┌────────────────┤ Authentication Configuration ├─────────────────┐
│  [ ] Cache Information   [*] Use MD5 Passwords                  │ 
│  [*] Use LDAP            [*] Use Shadow Passwords               │ 
│  [ ] Use NIS             [*] Use LDAP Authentication            │ 
│  [ ] Use IPAv2           [ ] Use Kerberos                       │ 
│  [ ] Use Winbind         [ ] Use Fingerprint reader             │ 
│                          [ ] Use Winbind Authentication         │ 
│                          [*] Local authorization is sufficient

───────────────┤ LDAP Settings ├─────────────────┐
│                                                   │ 
│          [ ] Use TLS                              │ 
│  Server: ldap://192.168.60.65____________________ │ 
│ Base DN: dc=ve,dc=cn
```


* 配置samba
>vim /etc/samba/smb.conf
```
[global]
        workgroup = MYGROUP
        server string = Samba Server Version %v
        log file = /var/log/samba/log.%m
        max log size = 50

        security = user
        passdb backend = ldapsam:ldap://192.168.60.65/
        ldap suffix = "dc=ve,dc=cn"
        ldap group suffix = "ou=Group"
        ldap user suffix = "ou=People"
        ldap admin dn = "cn=root,dc=ve,dc=cn"
        ldap delete dn = no
        ldap passwd sync = yes
        ldap ssl = off
        map to guest = Bad User  #将主机不能识别的用户映射成guest，访问是免去输出用户名密码,以匿名用户权限访问

        load printers = no
        cups options = raw
        create mask = 0777
        directory mask = 0777

[Anonymouse]
        browseable = yes
        writeable = yes
        public = yes
        path = /samba/anonymouse

[公共]
        comment = Public Directories
        path = /samba/public
        browseable = yes
        guest ok = yes
        writable = yes

[HR]
        comment = HR Directories
        path = /samba/hr
        browseable = yes
        writable = yes
        valid users = 150326004,@hr

[IT]
        comment = IT Directories
        path = /samba/it
        browseable = yes
        writable = yes
        valid users = @it            #ldap验证组，必须是英文组名
```
```
smbpasswd -w 341@ve.cn     #openldap服务端管理员cn=root,dc=ve,dc=cn的密码(341@ve.cn)

service smb start
service nmb start
chkconfig smb on
chkconfig nmb on
```

* 为ldap用户添加samba属性才可以通过samba用户验证
```
smbpasswd -a 150326018
```


* 为了方便用户自己修改自己的samba密码需要添加access to attrs=sambaNTPassword
```
access to attrs=userPassword,mail,sambaNTPassword
      by anonymous auth
      by dn="cn=admin,dc=ve,dc=cn" write
      by self write
```


* samba windows客户端清除用户网络连接缓存
```
net use               #查看IPC连接
net use * /d /y       #删除连接缓存
```