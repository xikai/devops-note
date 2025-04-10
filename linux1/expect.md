# expect语法
```sh
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
```

* if分支结构
```sh
#!/usr/bin/expect
set test [lindex $argv 0]
if { "$test" == "apple" } {
    puts "$test"
} else {
    puts "not apple"
}
```

* switch分支结构
```sh
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
```

* for循环结构
```sh
#!/usr/bin/expect
for {set i 0} {$i<4} {incr i} {   #incr递增,等同于i++
    puts "$i"
}

foreach  i { 1 3 5 7 9 } {
    puts "$i"
}
```

* while循环结构
```sh
#!/usr/bin/expect
set i 1
while {$i<4} {
        puts "$i"
        incr i
}
```

* 函数定义
```sh
#!/usr/bin/expect
proc test {} {
    puts "ok"
}
test
```


* 一个简单的expect ssh脚本：
```sh
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
```

# authy自动获取mfa令牌
- [安装authy命令行工具](https://github.com/momaek/authy)
```sh
mv authy-darwin-amd64 /usr/local/bin/authy
authy --help

authy account #登陆帐号
authy fuzz  #模糊搜索您的otp令牌(不区分大小写)
```
```sh
#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

ENV=$1
SSH_CMD="ssh -p 2222 -i ~/.ssh/id_rsa"

case $ENV in
    test)
        SSH_USER="test-xikai"
        SSH_HOST="jumpserver-test-website.vevor-internal.net"
        OTP_CODE=$(authy fuzz -a 'JumpServer-dlz: xikai@test'|jq -r '.items[0].subtitle | split("Code: ")[1] | split(" ")[0]')
        ;;
    prod)
        SSH_USER="xikai"
        SSH_HOST="10.30.33.120"
        OTP_CODE=$(authy fuzz -a "JumpServer-dlz: xikai@prod"|jq -r '.items[0].subtitle | split("Code: ")[1] | split(" ")[0]')
        ;;
    *)
        echo "Invalid environment: $ENV"
        exit 1
        ;;
esac

expect -c "
    set timeout 60
    spawn $SSH_CMD $SSH_USER@$SSH_HOST
    expect {
        \"*yes/no\" {send \"yes\r\";exp_continue}
        \"*]:\" {send \"${OTP_CODE}\r\"}
    }
    expect {
        \"Opt>\" {send \"p\r\"; interact}
    }
    expect eof
"
```

* 参考文档
  - https://blog.csdn.net/u010820857/article/details/89925274
  - https://github.com/dunwu/linux-tutorial/blob/master/docs/linux/expect.md
  - https://www.iots.vip/post/iterm2-jumpserver-totp-autocomplete.html