https://jenkins.io/doc/
https://www.k8stech.net/jenkins-docs/
https://www.w3cschool.cn/jenkins/

# groovy
http://www.groovy-lang.org/semantics.html
https://www.qikqiak.com/post/groovy-simple-tutorial/
https://cloud.tencent.com/developer/article/1358357


#插件
GIT plugin
Git Client Plugin
generic-webhook-trigger				    [webhook解发jenkins job]
multibranch-scan-webhook-trigger  		[webhook触发jenkins多分支 仓库扫描(只构建有变更的分支)]
Job Cacher                              [job cache 从一个docker agent到下一个docker agent ]
Publish Over SSH                        [通过ssh插件执行远程命令、上传文件到远程服务器]
Role-based Authorization Strategy       [权限管理插件]
Maven Integration plugin



#备份jenkins (jobs & config)
rsync -avz --delete --partial --exclude='workspace/' --exclude='jobs/*/builds/*/' -e 'ssh -p 1022' /data/jenkins/ root@172.31.40.180:/data/jenkins_bak
rsync -avz --delete --partial --exclude='workspace/' --exclude='jobs/*/builds/*/' -e 'ssh -i /root/.ssh/aws-ec2.pem -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no' /data/jenkins/ root@172.31.40.180:/data/jenkins_bak