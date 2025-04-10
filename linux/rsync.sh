rsync官网：http://rsync.samba.org/


#推送文件同步
rsync -avzp --delete --partial -e "ssh -p 2222 -i /root/.ssh/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no" /data/www/test/ root@192.168.181.128:/data/www/test

#拉取文件同步
rsync -avzp --delete --partial -e "ssh -p 2222 -i /root/.ssh/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no" root@192.168.181.129:/data/www/test/ /data/www/test


# --delete 是指如果服务器端删除了这一文件，那么客户端也把相应文件删除，保持真正的一致
# --partial 断点续传  -P: 是包含了 "–partial –progress" 部分传送和显示进度

#"/data/www/img/" 最后的"/"如果不加,rsync服务端/data/www/img目录下会新增一个img目录 如：/data/www/img/img
rsync -avz --delete --partial --exclude='workspace/' --exclude='jobs/*/modules/' /data/jenkins/ root@192.168.221.52:/data/jenkins   
#--exclude-from=/etc/rsync-exclude-php.list 将要排除的文件目录写在列表中
cat /etc/rsync-exclude-php.list
.git/
@runtime


