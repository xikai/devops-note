卸载flannel网络步骤：
```
#第一步，在master节点删除flannel
kubectl delete -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#第二步，在node节点清理flannel网络留下的文件
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /var/lib/cni/
rm -f /etc/cni/net.d/*
注：执行完上面的操作，重启kubelet

#第三步，应用calico相关的yaml文件
```
总结：此种方式也适用于flannel网络出现问题，要重新安装flannel时；