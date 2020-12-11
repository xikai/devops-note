* https://nanos.cloud/
* https://nanocloud.readthedocs.io/projects/guide/zh_CN/latest/index.html#


### 安装器安装nano
```
wget https://nanos.cloud/files/nano_installer_1.2.0.tar.gz
tar -xzf nano_installer_1.2.0.tar.gz
cd nano_installer
./installer
```

### 启动组件
```
cd /opt/nano/core
./core start
cd ../cell
./cell start
 cd ../frontend
./frontend start
```


### 遇到的问题
```
安装Windows Server 2019后，发现从控制台进入，无法发送Ctrl + Alt + Del快捷键，解决办法是使用VNC客户端进行连接。

点击资源监控的时候浏览器提示内存不足，这个情况应该Windows虚拟机会出现此问题，解决办法是安装virtio驱动和qeum agent，
下载地址为：https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.173-9/virtio-win.iso，
不然nano查看虚拟机资源监控会卡住。
```