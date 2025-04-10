https://jenkins.io/doc/
https://www.k8stech.net/jenkins-docs/
https://www.w3cschool.cn/jenkins/

# groovy
http://www.groovy-lang.org/semantics.html
https://www.qikqiak.com/post/groovy-simple-tutorial/
https://cloud.tencent.com/developer/article/1358357

# python-jenkins
https://python-jenkins.readthedocs.io/en/latest/

#插件
GIT plugin
Git Client Plugin
generic-webhook-trigger				    [webhook解发jenkins job]
multibranch-scan-webhook-trigger  		[webhook触发jenkins多分支 仓库扫描(只构建有变更的分支)]
Job Cacher                              [job cache 从一个docker agent到下一个docker agent ]
Publish Over SSH                        [通过ssh插件执行远程命令、上传文件到远程服务器]
Role-based Authorization Strategy       [权限管理插件]
Maven Integration plugin

# 共享库（shared library）
https://www.jenkins.io/zh/doc/book/pipeline/shared-libraries/
https://www.qikqiak.com/post/jenkins-shared-library-demo/

#备份jenkins (jobs config)
rsync -avz --delete --partial --exclude='workspace/' --exclude='jobs/*/builds/*/' -e 'ssh -p 1022' /data/jenkins/ root@172.31.40.180:/data/jenkins_bak
rsync -avz --delete --partial --exclude='workspace/' --exclude='jobs/*/builds/*/' -e 'ssh -i /root/.ssh/aws-ec2.pem -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no' /data/jenkins/ root@172.31.40.180:/data/jenkins_bak

#清理jenkins历史构建数据
rm -rf jobs/*/builds/*/
#删除5天以前的构建历史
find ./jobs/*/builds/ -mindepth 1 -maxdepth 1 -ctime +10 -type d -exec rm -r {} \;


#关闭basic-msoa-goods正在构建的ID为255以下的job
def jobName = "basic-msoa-goods"
def maxNumber = 255
  
Jenkins.instance.getItemByFullName(jobName).builds.findAll {
  it.number <= maxNumber
}.each {
  it.delete()
}

#jenkins systemd日志
/var/log/jenkins/jenkins.log