ssh -i ~/.ssh/aws-ec2.pem centos@52.39.117.244 -f -N -D 7070
ssh root@47.75.241.49 -f -N -D 7070

#配置Terminal终端通过ss上网
vim /etc/profile
alias proxy='export all_proxy=socks5://127.0.0.1:7070'
alias unproxy='unset all_proxy'