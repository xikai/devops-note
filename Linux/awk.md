* https://zh.wikipedia.org/wiki/AWK
* https://www.ruanyifeng.com/blog/2018/11/awk.html
* https://www.cnblogs.com/emanlee/p/3327576.html
* https://mp.weixin.qq.com/s/OFjy_EIJKCLwF7rwAaeOFw
* https://cloud.tencent.com/developer/article/1159061

# awk命令结构
```
awk 'BEGIN{ commands } pattern{ commands } END{ commands }'
```
* 首先执行 BEGIN {commands} 内的语句块，注意这只会执行一次，经常用于变量初始化，头行打印一些表头信息，只会执行一次，在通过stdin读入数据前就被执行；
* 从文件内容中读取一行，注意awk是以行为单位处理的，每读取一行使用 pattern{commands} 循环处理 可以理解成一个for循环，这也是最重要的部分；
* 最后执行 END{ commands } ,也是执行一次，在所有行处理完后执行，一帮用于打印一些统计结果。


# awk内置变量
```
NR             已经读出的记录数
FNR            当前输入的记录号
FILENAME       正在处理的数据文件文件名

ARGC    命令行参数的个数
ARGV    命令行参数序列数组，下标从0开始。

ARGIND  命令行中当前文件的位置
eg： 有两个文件a 和b
awk '{if(ARGIND==1){print "处理a文件"} if(ARGIND==2){print "处理b文件"}}' a b

#多分隔符（空隔和冒号）
netstat -antp|grep ESTABLISHED |awk -F'[ :]+' '{print $5}'

#{}中多个语句用;分隔
awk '/tom/ {wage=$2+$3; printf wage}' file    
```

# awk数组
```
可以用数值作数组索引(下标),可以用字符串作数组索引(下标)
Tarray[1]="cheng mo"
Tarray["first"]="cheng"

注意：数组下标是从1开始

eg:
awk 'BEGIN{tB["a"]="a1";tB["b"]="b1";if(tB["c"]!="1"){print "no found";};for(k in tB){print k,tB[k];}}'
cat a.txt b.txt | awk '{a[$1]+=$2} END{for(i in a ) print i,a[i]}'
```

# awk流程控制
```
#通过if else语句流程控制
awk '{if($1 <$2) print $2}' file
awk '{if($1 < $2) {count++; print "ok"}}' file

#通过while语句实现循环
awk '{i=1;while(i<NF) {print NF,$i;i++}}' file  

#通过for语句实现循环
awk '{for(i=1;i<NF;i++) {print NF,$i}}'   file  

awk '{if(NR>1 && $3>0) {print $0}}'
```

# awk内置函数
```
int()           返回整数
rand()          返回随机数 0至1的小数
sub(r,s)        在$0中匹配第一次出现的符合模式的字符串，相当于 sed 's/r/s/'
sub(r,s,$1)     在$1中匹配第一次出现的符合模式的字符串，相当于 sed 's/r/s/'
gsub(r,s)       在$0中匹配所有出现的符合模式的字符串，相当于 sed 's/r/s/g'
gsub(r,s,$1)    在$1中匹配所有出现的符合模式的字符串，相当于 sed 's/r/s/g'
substr(s,p)     返回字符串s中从p开始的后缀部分
substr(s,p,n)   返回字符串s中从p开始长度为n的后缀部分
index(s,t)      返回s中字符串t的第一位置
length(s)       返回s长度
match(s,r)      测试s是否包含匹配r的字符串,返回r的起始位置或0(没有匹配到)
split(s,a)      将s分成数组a
sprint(fmt,exp) 返回经fmt格式化后的exp
tolower()       转换字符串为小写
toupper         转换字符串为大写
system()        在awk中执行shell命令行
close("cmd")    
```

# next
```
next 进入下一行：
zoer@ubuntu:~$ cat data   
1000  
naughty 500  
cc 400  
zoer 100  
zoer@ubuntu:~$ awk '{if(NR==1){next} print $1,$2}' data   
naughty 500  
cc 400  
zoer 100  
```

# getline 读取下一行
```
[root@localhost ~]# cat a.txt
abc
test
123
456
789
[root@localhost ~]# awk '/test/ {getline d; print d}' a.txt     #getline d  将匹配条件的下一行赋给变量d。 如果不写变量时，默认将下一行的内容赋值给$0
123
[root@localhost ~]# awk '/test/ {for(i=0;i<=3;i++){getline; print $0}}' a.txt
123
456
789
789
```
```
#getline还可以从文件、标准输入、管道中获取输入内容
getline<file                   $0,NF 
getline var<file               var 
"cmd"|getline                  $0,NF 
"cmd"|getline var              var 
```