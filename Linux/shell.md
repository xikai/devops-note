# shell
* /bin/sh 是/bin/bash的符号链接
```
# ll /bin/sh
lrwxrwxrwx 1 root root 4 Aug 24 19:06 /bin/sh -> bash

# sh就是开启了POSIX标准的bash，遵循POSIX规范：“当某行代码出错时，不继续往下解释”。bash 就算出错，也会继续向下执行。
```
```
双小括号(( ))： 整数扩展。这种扩展计算是整数型的计算，不支持浮点型 
if (($i<5))

[]和Test中可用的比较运算符只有==和!=，两者都是用于字符串比较的，不可用于整数比较，整数比较只能使用-eq，-gt这种形式。无论是字符串比较还是整数比较都不支持大于号小于号。
if [ $i == "5" ]
if [ $i != "abc" ]
if [ $a -ne 1 -a $a != 2 ]  
if [ $a -ne 1] && [ $a != 2 ]

使用[[ ... ]]条件判断结构，而不是[ ... ]，能够防止脚本中的许多逻辑错误。比如，&&、||、<和> 操作符能够正常存在于[[ ]]条件判断结构中，但是如果出现在[ ]结构中的话，会报错。
if [[ $a != 1 && $a != 2 ]]  
```

# 监控进程
```sh
#!/bin/sh
#while true; do
#  ...
#  condition || break
#done

while true
do
   ps aux|grep ssh|grep -v grep
   if [ $? == 0 ] ;then
      sleep 3
      continue
   else
      echo "00000000"
      break
   fi
done
```

# 按行循环读入文件
```sh
echo " cat file while read line"
cat test.txt |while read line  
do  
  echo $line;  
done  

echo "while read line <file"  
while read line  
do  
  echo $line;  
done <test.txt 
```
```sh
kubectl get roles --all-namespaces > k8s-pci/roles.txt
kubectl get roles --all-namespaces |grep -v 'NAME' | awk '{print $1,$2}' |while read ns name
do
  kubectl describe role $name -n $ns >>k8s-pci/roles.txt
done
```

# set
```sh
-e 若指令返回值不等于0，则立即退出shell （+e 关闭退出shell功能）
-x  交互执行shell ，和sh -x a.sh 一样
-o pipefail 在有管道的命令中默认返回最后一个管道命令的返回值，若设置-o pipefail命令则返回从右往左第一个不为0的返回值
[root@localhost ~]# cat test.sh
#!/bin/bash
ls /a.txt |echo "hi" >/dev/null
echo $?
[root@localhost ~]# ./test.sh
ls: cannot access /a.txt: No such file or directory
0

[root@localhost ~]# cat test.sh
#!/bin/bash
set -o pipefail
ls /a.txt |echo "hi" >/dev/null
echo $?
[root@localhost ~]# ./test.sh
ls: cannot access /a.txt: No such file or directory
2

set -eo pipefail  若命令或管道命令中有一个管道返回值为非0，则立即退出shell。

选项名	     开关缩写	    描述
allexport	-a	        打开此开关，所有变量都自动输出给子Shell。
noclobber	-C	        防止重定向时文件被覆盖。
noglob	    -d	        在路径和文件名中，关闭通配符。

打开该选项
/> set -o allexport   #等同于set -a
#关闭该选项
/> set +o allexport  #等同于set +a
#列出当前所有选项的当前值。
/> set -o
allexport         off
braceexpand   on
emacs             on
errexit            off
errtrace          off
functrace        off
hashall            on
histexpand      on
... ...
```

# envsubst 用环境变量值替换文件中对应变量名
```sh
[root@xinnet-baoleiji ~]# cat file.yml
I am: ${name}
[root@xinnet-baoleiji ~]# export name="xikai" && envsubst < file.yml
I am: xikai
```