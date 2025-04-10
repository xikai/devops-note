# [windows wsl](https://docs.microsoft.com/zh-cn/windows/wsl/install)
* 在windows上运行linux虚拟机
```PowerShell
#安装 WSL 和 Linux 的 Ubuntu 发行版
PowerShell> wsl --install
#更新wsl内核
PowerShell> wsl --update
#回滚到 WSL Linux 内核的上一版本
PowerShell> wsl --update rollback 
#关闭wsl虚拟机
PowerShell> wsl --shutdown

#安装特定的 Linux 发行版
PowerShell> wsl --list --online
PowerShell> wsl --install --distribution <Distribution Name>

##列出已安装的 Linux 发行版和 wsl版本
PowerShell> wsl -l -v
#更改wsl版本
PowerShell> wsl --set-version <distro name> 2

#设置默认 Linux 发行版
PowerShell> wsl --set-default <Distribution Name>

#通过 PowerShell 或 CMD 运行特定的 Linux 发行版
PowerShell> wsl --distribution <Distribution Name> --user <User Name>

#注销或卸载 Linux 发行版
PowerShell> wsl --unregister <DistributionName>
```