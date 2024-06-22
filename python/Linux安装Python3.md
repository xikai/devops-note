**安装Python依赖**：
```
yum install openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel
```

**由于Python在linux不支持我们以可执行程序的方式安装，所以需要我们选择对应的版本源码**
>安装源码下载站点：
https://www.python.org/ftp/python/

**以Python3.6为例**：
```
wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tgz
tar -zxvf Python-3.6.2.tgz
cd Python-3.6.2/
./configure --prefix=/usr/local/python3
make && make install

ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
```
由于python2被我们的系统所使用，所以这里保守的办法是Python3的东西都起名叫做xx3
当然你也可以修改默认的系统使用Python2地址的导入信息，来使Python3成为默认python环境。

**为Python2设置pip**
* 在linux下，现在已经是默认自带了Python2
但是可能部分系统类型还没有pip这个工具，那么需要我们额外的手动安装
```
yum -y install epel-release
yum install python-pip
```

# ubuntu通过ppa:deadsnakes源 安装python
```
apt-get install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt-get -y update
apt-get install -y python3.7
```