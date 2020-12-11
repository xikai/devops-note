* 创建待认证的用户
```bash
mkdir /home/ldapusers
useradd -d /home/ldapusers/ldapuser01 ldapuser01
useradd -d /home/ldapusers/ldapuser02 ldapuser02
useradd -d /home/ldapusers/ldapuser03 ldapuser03
echo "ldap123" |passwd --stdin ldapuser01
echo "ldap123" |passwd --stdin ldapuser02
echo "ldap123" |passwd --stdin ldapuser03
```

* 安装migrationtools配置迁移工具
```bash
yum install -y migrationtools

cd /usr/share/migrationtools
vim migrate_common.ph
---------------------------------------------
# Default DNS domain
$DEFAULT_MAIL_DOMAIN = "ve.cn";

# Default base
$DEFAULT_BASE = "dc=ve,dc=cn";
---------------------------------------------
```

* 创建认证账户文件
```
主要的概念：
dn：唯一区分名
dc：所属区域
ou：所属组织
cn/uid：全名/登录ID
```

* 运行脚本migrate_base.pl，它会创建根项，并为 Hosts、Networks、Group和 People 等创建低一级的组织单元，指定为base.ldif文件，这里我们只有下面这3个
>./migrate_base.pl >/etc/openldap/base.ldif

>vim /etc/openldap/base.ldif
```
dn: dc=ve,dc=cn
dc: ldap
objectClass: top
objectClass: domain

dn: ou=People,dc=ve,dc=cn
ou: People
objectClass: top
objectClass: organizationalUnit

dn: ou=Group,dc=ve,dc=cn
ou: Group
objectClass: top
objectClass: organizationalUnit

......
```

* 创建用户和组的数据库文件
```bash
cd /etc/openldap
grep ldapuser /etc/passwd >user.txt
grep ldapuser /etc/group >group.txt
/usr/share/migrationtools/migrate_passwd.pl user.txt user.ldif
/usr/share/migrationtools/migrate_group.pl group.txt group.ldif
```

* 检查搜索LDAP目录条目
```
ldapsearch -x -b -L "dc=ve,dc=cn"
---------------------------------------------
# extended LDIF
#
# LDAPv3
# base <-L> with scope subtree
# filter: dc=ve,dc=cn
# requesting: ALL
#

# search result
search: 2
result: 34 Invalid DN syntax
text: invalid DN

# numResponses: 1
---------------------------------------------

/etc/init.d/slapd restart
```

* 迁移系统用户到ldap数据库
```
ldapadd -D "cn=Manager,dc=ve,dc=cn" -W -x -f /etc/openldap/base.ldif
Enter LDAP Password: #上面slappasswd创建的密码

ldapadd -D "cn=Manager,dc=ve,dc=cn" -W -x -f /etc/openldap/user.ldif
Enter LDAP Password: #上面slappasswd创建的密码

ldapadd -D "cn=Manager,dc=ve,dc=cn" -W -x -f /etc/openldap/group.ldif
Enter LDAP Password: #上面slappasswd创建的密码
```
```
ldapsearch -x -b "dc=ve,dc=cn"
```