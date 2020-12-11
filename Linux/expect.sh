expect语法：
set 变量名 变量值
set username "xikai"
set ip [lindex $argv 0]    #传递参数赋值,$argv内置变量
set list [exec ls]        #调用系统命令赋值给变量list
set i [expr {$i + 1}]   #expect里的加减法
send [exec whoami]         #send发送执行系统命令后的结果

puts 打印
puts $username
puts $ip

expect {...}        里面的多行记录，从上向下扫描匹配，谁先匹配谁先处理
interact             执行完成后保持交互状态，把控制权交给控制台，这个时候就可以手工操作了。如果没有这一句登录完成后会退出，而不是留在远程终端上。如果你只是登录过去执行
exp_continue        匹配一个关健字后从头开始匹配，而不是接下来匹配第二个关健字
exp_internal        打开调式模式(非0，0为关闭)，将整个操作过程显示出来,放在spawn命令后
send_user            等于puts+send,将字符串发送并打印到标准输出
更多参考man expect 或    http://www.doc88.com/p-671126483324.html


if 分支
#!/usr/bin/expect
set test [lindex $argv 0]
if { "$test" == "apple" } {
    puts "$test"
} else {
    puts "not apple"
}

switch  分支结构
#!/usr/bin/expect
set color [lindex $argv 0]
switch $color {
    apple {
        puts "apple is blue"
    }
    banana {
        puts "banana is yellow "
    }
}

for 循环结构
#!/usr/bin/expect
for {set i 0} {$i<4} {incr i} {   #incr递增,等同于i++
    puts "$i"
}

foreach  i { 1 3 5 7 9 } {
    puts "$i"
}


while  循环结构
#!/usr/bin/expect
set i 1
while {$i<4} {
        puts "$i"
        incr i
}

函数定义
#!/usr/bin/expect
proc test {} {
    puts "ok"
}
test



-------------------------------------------------------------
eg:
一个简单的expect ssh脚本：
#!/usr/bin/expect
set timeout 60
set passwd "fanhougame"

spawn ssh root@192.168.0.220
exp_internal 1            #打开调式模式(非0，0为关闭)，将整个操作过程显示出来
expect {
   "(yes/no)?" {send "yes\r";exp_continue}        #匹配一个关健字后从头开始匹配，而不是接下来匹配第二个关健字
   "password:" {send "$passwd\r"}
}

expect -re "\](\$|#)"
send "ls\r"
send "exit\r"
expect eof

-------------------------------------------------------------
eg:
在shell中嵌入expect
#!/bin/sh
passwd="fanhougame"

/usr/bin/expect -c "
set timeout 60
spawn ssh root@192.168.0.220
expect {
   \"(yes/no)?\" {send \"yes\r\"}
   \"password:\" {send \"${passwd}\r\"}
}
expect -re \"\](\$|#)\"
send \"ls\r\"
send \"exit\r\"
expect eof"
