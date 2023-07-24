SED
http://man.linuxde.net/sed


#只查看文件的第100行到第200行(-n只有经过sed 特殊处理的那一行(或者动作)才会被列出来)
sed -n '100,200p' mysql_slow_query.log

#删除1到100行，并替换datafile所有行中的My为Your
sed -e '1,10d' -e 's/My/Your/g' datafile

#在匹配行下一行插入aaaa
sed '/def/a\aaaa' datafile

#在匹配行上一行插入aaaa
sed '/def/i\aaaa' datafile

#将匹配行修改为aaaa
sed '/def/c\aaaa' a.txt 

#如果在文件datafile的某一行匹配到My，就在该行后读入文件introduce.txt的内容。如果出现My的行不止一行，则在出现My的各行后都读入introduce.txt文件的内容。
sed '/My/r introduce.txt' datafile

#文件datafile中匹配到hrwang的行 标准重定向到me.txt文件中
sed -n '/hrwang/w me.txt' datafile

#love被标记为1，所有loveable会被替换成lovers，而且替换的行会被打印出来。  
sed -n 's/\(love\)able/\1rs/p' 

#把1--10行内所有abcde转变为大写，注意，正则表达式元字符不能使用这个命令
sed '1,10y/abcde/ABCDE/' 

#!取反(打印非abc开头的)
sed -n '/^abc/!p' a.txt 

#正则表达式 \w\+ 匹配每一个单词，使用 [&] 替换它，& 对应于之前所匹配到的单词
echo this is a test line | sed 's/\w\+/[&]/g' 
[this] [is] [a] [test] [line]

#如果test被匹配，则移动到匹配行的下一行，替换这一行的aa，变为bb
sed '/test/n;s/aa/bb/' file
grep -rl profile jobs/*/config.xml |xargs sed -i '/profile/n;s/test/dev/'


--------------------------------------------------------------------------------
https://www.cnblogs.com/emanlee/p/3327576.html
https://mp.weixin.qq.com/s/OFjy_EIJKCLwF7rwAaeOFw

awk内置变量
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

-------------------------------------------------------------
BEGIN模块后紧跟着动作块，这个动作块在awk处理任何输入文件之前执行。所以它可以在没有任何输入的情况下进行测试。它通常用来改变内建变量的值，如OFS,RS和FS等，以及打印标题。
END不匹配任何的输入文件，但是执行动作块中的所有动作，它在整个输入文件处理完成后被执行

-------------------------------------------------------------
awk数组
可以用数值作数组索引(下标),可以用字符串作数组索引(下标)
Tarray[1]="cheng mo"
Tarray["first"]="cheng"

注意：数组下标是从1开始

eg:
awk 'BEGIN{tB["a"]="a1";tB["b"]="b1";if(tB["c"]!="1"){print "no found";};for(k in tB){print k,tB[k];}}'
cat a.txt b.txt | awk '{a[$1]+=$2} END{for(i in a ) print i,a[i]}'


-------------------------------------------------------------
awk流程控制
#通过if else语句流程控制
awk '{if($1 <$2) print $2}' file
awk '{if($1 < $2) {count++; print "ok"}}' file

#通过while语句实现循环
awk '{i=1;while(i<NF) {print NF,$i;i++}}' file  

#通过for语句实现循环
awk '{for(i=1;i<NF;i++) {print NF,$i}}'   file  

awk '{if(NR>1 && $3>0) {print $0}}'

-------------------------------------------------------------
awk内置函数
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


-------------------------------------------------------------
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


getline 读取下一行
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

#getline还可以从文件、标准输入、管道中获取输入内容
getline<file                   $0,NF 
getline var<file               var 
"cmd"|getline                  $0,NF 
"cmd"|getline var              var 