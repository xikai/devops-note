https://jenkins.io/doc/
https://www.w3cschool.cn/jenkins/


#插件
GIT plugin
Git Client Plugin
generic-webhook-trigger				[webhook解发jenkins job]
multibranch-scan-webhook-trigger  		[webhook触发jenkins多分支 仓库扫描(只构建有变更的分支)]
Job Cacher                                                     [job cache 从一个docker agent到下一个docker agent ]
Publish Over SSH                                		[通过ssh插件执行远程命令、上传文件到远程服务器]
Role-based Authorization Strategy          		[权限管理插件]
Maven Integration plugin



#备份jenkins (jobs & config)
rsync -avz --delete --partial \
--exclude='workspace/' \
--exclude='jobs/*/modules/' \
--exclude='jobs/*/builds/*/archive/' \
-e "ssh -i /root/.ssh/aws-ec2.pem -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no" /data/jenkins/ root@172.31.40.180:/data/jenkins

rsync -avz --delete --partial --exclude='workspace/' --exclude='jobs/*/modules/' /data/jenkins/ root@192.168.221.52:/data/jenkins
