>将密码,sshkey等私密信息放在secret对象中比直接放在pod或docker image中更安全,也更便于使用和分发

* 手动创建 Secret
```
$ echo -n "admin" | base64
YWRtaW4=
$ echo -n "1f2d1e2e67df" | base64
MWYyZDFlMmU2N2Rm
```

>vim secret.yaml
```
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:  #data域中的值必须是base64编码值
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```
```
$ kubectl create -f ./secret.yaml
secret "mysecret" created
```

* 获取 secret
```
$ kubectl get secret
$ kubectl get secret mysecret -o yaml
```

* 解码base64
```
$ echo "MWYyZDFlMmU2N2Rm" | base64 --decode
1f2d1e2e67df
```

* 在 pod 中使用 volume 挂在 secret 的例子
```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:              #在容器中挂载secret
    - name: foo
      mountPath: "/etc/foo"    	#想要该 secret 挂到pod的目录
      readOnly: true
  volumes:                    #指定secret对象
  - name: foo					        # 随意命名
    secret:
      secretName: mysecret  	#secret 对象的名字
```
```
# 在pod容器中查询secretKey
$ ls /etc/foo/
username
password
$ cat /etc/foo/username
admin
$ cat /etc/foo/password
1f2d1e2e67df
```


* 将 secret 作为 pod 中的环境变量使用
```
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
  restartPolicy: Never
```
```
# 在pod容器中查询环境变量
$ echo $SECRET_USERNAME
admin
$ echo $SECRET_PASSWORD
1f2d1e2e67df
```

* 创建tls secret
>使用己有的ssl证书
```
kubectl create secret tls dadi01-net-secret --key cert/dadi01.net.key --cert cert/dadi01.net.pem -n kube-test
```

* 从指定文件、字符串创建secret
```
kubectl create secret generic dadi01-net-secret --from-file=tls.crt=cert/dadi01.net.pem --from-file=tls.key=cert/dadi01.net.key --from-file=ca.crt=cert/dadi01.net.ca -n kube-test
```

* 创建docker-registry secret从私有仓库拉取镜像
```
kubectl create secret docker-registry myregistrykey --docker-server=reg.dadi01.cn --docker-username=admin --docker-password=Harbor12345 --namespace=kube-test
```