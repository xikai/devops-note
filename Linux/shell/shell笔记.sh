#变量替换
echo ${HOSTNAME}
zabbix-172-31-24-10
计算变量长度
echo ${#HOSTNAME}     //19

变量截取
抽取string的子串
#{HOSTNAME:5}     //从position个位置开始截取子串到结束  x-172-31-24-10
#{HOSTNAME:5:10}   //从position处开始截取长度为10的子串  x-172-31-2
删除子串 
${string#substring} //删除string开头处与substring匹配的最短子串 
${string##substring} //删除string开头处与substring匹配的最长子串 
替换子串 
${HOSTNAME/zabbix/aaaa}  //仅替换第一次与字符串"zabbix"相匹配的子串  aaaa-172-31-24-10
${HOSTNAME//2/8}         //替换所有与substring相匹配的子  zabbix-178-31-84-10


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

