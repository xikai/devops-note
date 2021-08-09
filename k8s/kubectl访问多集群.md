### 指定config文件
```
scp root@<master ip>:/.kube/config .
kubectl --kubeconfig ./config get nodes
```

### 合并config文件
* https://kubernetes.io/zh/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
* https://blog.csdn.net/u013360850/article/details/83315188

* 查看是否有名为 KUBECONFIG 的环境变量。 如有，保存 KUBECONFIG 环境变量当前的值，以便稍后恢复
```
echo $KUBECONFIG
export  KUBECONFIG_SAVED=$KUBECONFIG
```

* 修改两个.kube/config的集群名和user名
```
#vim $HOME/.kube/config-alitest修改集群名（:1,$ s/kubernetes/kubernetes-alitest/g）
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://120.79.239.134:6443
  name: kubernetes-alitest
contexts:
- context:
    cluster: kubernetes-alitest
    user: kubernetes-alitest-admin
  name: kubernetes-alitest-admin@kubernetes-alitest
current-context: kubernetes-alitest-admin@kubernetes-alitest
kind: Config
preferences: {}
users:
- name: kubernetes-alitest-admin

#vim $HOME/.kube/config-xinnet （:1,$ s/kubernetes/kubernetes-xinnet/g）  
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://apiserver.dadi01.net:6443
  name: kubernetes-xinnet
contexts:
- context:
    cluster: kubernetes-xinnet
    user: kubernetes-xinnet-admin
  name: kubernetes-xinnet-admin@kubernetes-xinnet
current-context: kubernetes-xinnet-admin@kubernetes-xinnet
kind: Config
preferences: {}
users:
- name: kubernetes-xinnet-admin
```
* 将两个cluster配置文件合并
>KUBECONFIG 环境变量不是必要的。 如果 KUBECONFIG 环境变量不存在，kubectl 使用默认的 kubeconfig 文件，$HOME/.kube/config。如果 KUBECONFIG 环境变量存在，kubectl 使用 KUBECONFIG 环境变量中列举的文件合并后的有效配置。
```
echo -e "export KUBECONFIG=$HOME/.kube/config-alitest:$HOME/.kube/config-xinnet" >>~/.bash_profile

#删除KUBECONFIG变量 则删除合并集群配置
unset KUBECONFIG
export KUBECONFIG=$KUBECONFIG_SAVED

```

* 查看合并后的 kubeconfig
```
kubectl config view
#kubectl config --kubeconfig ~/.kube/config-alitest view
#kubectl config --kubeconfig ~/.kube/config-xinnet view
```

* 查看集群
```
#获取集群列表
kubectl config get-contexts

#查看当前所在集群
kubectl config current-context
```

* 切换集群
```
kubectl config use-context kubernetes-alitest-admin@kubernetes-alitest
kubectl config use-context kubernetes-xinnet-admin@kubernetes-xinnet
```

* 设置命令别名
vim ~/.bash_profile
```
alias kubetest='kubectl config use-context kubernetes-test-admin@kubernetes-test && kubectl get nodes'
alias kubeprod='kubectl config use-context 245517456507461168-ca625dae386aa4423a64c6aec960791cf && kubectl get nodes'
```