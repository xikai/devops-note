一，Orcale安装准备
#安装依赖包
yum install binutils compat-libstdc++-33 compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc-common glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel make numactl-devel sysstat unixODBC unixODBC-devel

#解析主机名
vim /etc/hosts
127.0.0.1 oradb1

#创建oracle用户组
groupadd dba
groupadd oinstall
useradd -g oinstall -G dba oracle
passwd oracle

#修改系统限制
vim /etc/security/limits.conf
oracle              soft    nproc   2047
oracle              hard    nproc   16384
oracle              soft    nofile  1024
oracle              hard    nofile  65536

#调整系统内核参数
vim /etc/sysctl.conf
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 2147483648
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576

#使内核参数立即生效
/sbin/sysctl -p


#创建安装目录
mkdir -p /u01/app/oracle/product/11.2.0
chown -R oracle:oinstall /u01/app



二，静默安装oracle
#切换oracle用户
su - oracle

#设置环境变量
vim ~/.bash_profile
export ORACLE_BASE=/u01/app
export ORACLE_HOME=/u01/app/oracle/product/11.2.0
export PATH=/u01/app/oracle/product/11.2.0/bin:$PATH
export LD_LIBRARY_PATH=/u01/app/oracle/product/11.2.0/lib:$LD_LIBRARY_PATH
export ORACLE_SID=oradb1
export DISPLAY=192.168.10.51:0.0

#设置DISPLAY变量后root用户执行xhost
su - root
xhost +

#解压oracle安装包
unzip linux.x64_11gR2_database_1of2.zip >/dev/null 2>&1
unzip linux.x64_11gR2_database_2of2.zip >/dev/null 2>&1  

#创建oraInst.loc文件
su - root
vim /etc/oraInst.loc
inventory_loc=/u01/app/oraInventory
inst_group=oinstall

chown oracle:oinstall /etc/oraInst.loc
chmod 664 /etc/oraInst.loc

#安装图形界面
yum groupinstall "Desktop"
yum groupinstall "X Window System"
yum groupinstall "Chinese Support"
startx
#图形界面安装oracle(交互模式，需要图形界面)
su - oracle
cd database
./runInstaller

#静默模式安装oracle(非交互模式，不需要图形界面)
su - oracle
cd database
./runInstaller -silent -responseFile /usr/local/src/database/response/db_install.rsp

注：response文件配置db_install.rsp
less /usr/local/src/database/response/db_install.rsp |grep -v "#"|grep -v "^$"  
------------------------------------------------------------------------------------------------------ 
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=oradb1
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en,zh_CN
ORACLE_HOME=/u01/app/oracle/product/11.2.0
ORACLE_BASE=/u01/app
oracle.install.db.InstallEdition=EE
oracle.install.db.isCustomInstall=false
oracle.install.db.customComponents=oracle.server:11.2.0.1.0,oracle.sysman.ccr:10.2.7.0.0,oracle.xdk:11.2.0.1.0,oracle.rdbms.oci:11.2.0.1.0,oracle.network:11.2.0.1.0,oracle.network.listener:11.2.0.1.0,oracle.rdbms:11.2.0.1.0,oracle.options:11.2.0.1.0,oracle.rdbms.partitioning:11.2.0.1.0,oracle.oraolap:11.2.0.1.0,oracle.rdbms.dm:11.2.0.1.0,oracle.rdbms.dv:11.2.0.1.0,orcle.rdbms.lbac:11.2.0.1.0,oracle.rdbms.rat:11.2.0.1.0
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=oinstall
oracle.install.db.CLUSTER_NODES=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=oradb1
oracle.install.db.config.starterdb.SID=oradb1
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.config.starterdb.memoryOption=true
oracle.install.db.config.starterdb.memoryLimit=512
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.password.ALL=oracle
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.SYSMAN=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.control=DB_CONTROL
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=
oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=false
oracle.install.db.config.starterdb.dbcontrol.emailAddress=
oracle.install.db.config.starterdb.dbcontrol.SMTPServer=
oracle.install.db.config.starterdb.automatedBackup.enable=false
oracle.install.db.config.starterdb.automatedBackup.osuid=
oracle.install.db.config.starterdb.automatedBackup.ospwd=
oracle.install.db.config.starterdb.storageType=
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=
oracle.install.db.config.asm.ASMSNMPPassword=
MYORACLESUPPORT_USERNAME=
MYORACLESUPPORT_PASSWORD=
SECURITY_UPDATES_VIA_MYORACLESUPPORT=
DECLINE_SECURITY_UPDATES=true
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
------------------------------------------------------------------------------------------------------ 

#执行root.sh
/u01/app/oracle/product/11.2.0/root.sh


三，启动监听程序,创建数据库实例
#静默启动监听程序(为远程用户)
/u01/app/oracle/product/11.2.0/bin/netca /silent /responseFile /usr/local/src/database/response/netca.rsp

#静默dbca建库
/u01/app/oracle/product/11.2.0/bin/dbca -silent -responseFile /usr/local/src/database/response/dbca.rsp

注：response文件配置dbca.rsp
less /usr/local/src/database/response/dbca.rsp |grep -v "#"|grep -v "^$" 
------------------------------------------------------------------------------------------------------        
[GENERAL]
RESPONSEFILE_VERSION = "11.2.0"
OPERATION_TYPE = "createDatabase"
[CREATEDATABASE]
GDBNAME = "oradb1.qx.com"
SID = "oradb1"
TEMPLATENAME = "General_Purpose.dbc"
CHARACTERSET = "AL32UTF8"
NATIONALCHARACTERSET= "UTF8"
[createTemplateFromDB]
SOURCEDB = "myhost:1521:orcl"
SYSDBAUSERNAME = "system"
TEMPLATENAME = "My Copy TEMPLATE"
[createCloneTemplate]
SOURCEDB = "orcl"
TEMPLATENAME = "My Clone TEMPLATE"
[DELETEDATABASE]
SOURCEDB = "orcl"
[generateScripts]
TEMPLATENAME = "New Database"
GDBNAME = "orcl11.us.oracle.com"
[CONFIGUREDATABASE]
[ADDINSTANCE]
DB_UNIQUE_NAME = "orcl11g.us.oracle.com"
NODELIST=
SYSDBAUSERNAME = "sys"
[DELETEINSTANCE]
DB_UNIQUE_NAME = "orcl11g.us.oracle.com"
INSTANCENAME = "orcl11g"
SYSDBAUSERNAME = "sys"
------------------------------------------------------------------------------------------------------ 


四，连接数据库实例
sqlplus sys/oracle as sysdba
SQL>select name,value from v$parameter order by name;



