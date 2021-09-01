#监控进程
#!/bin/sh
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


#按行循环读入文件
echo " cat file whiel read line"
cat test.txt |while read line  
do  
  echo $line;  
done  

echo "while read line <file"  
while read line  
do  
  echo $line;  
done <test.txt 

#set
-e 若指令传回值不等于0，则立即退出shell。
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