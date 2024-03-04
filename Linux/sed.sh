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

#打印匹配行的第4，5行 （n匹配下一行）
sed -n '/upload_nexus/ {n;n;n;n;p;n;p;q}' file

# 在匹配文本行的 第3行后 添加文本内容
sed -i '/匹配行文本/ {n;n;n;a\
要添加的文本行1\
要添加的文本行2\
要添加的文本行3
}' jobs/*/config.xml