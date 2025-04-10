#!/bin/bash

CURRENT_DIR=$(dirname $0)
mkdir -p /data/jenkins/{jenkins_home,maven,maven_repo,tools}
cd /data/jenkins
wget https://vevor-packages.oss-cn-shanghai.aliyuncs.com/jenkins/jsn.tar.gz
wget https://vevor-packages.oss-cn-shanghai.aliyuncs.com/jenkins/tools.tar.gz
tar xf  jsn.tar.gz 
tar xf tools.tar.gz -C /data/jenkins/tools
chown -R 1000:1000 /data/jenkins

sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g'  /etc/ssh/ssh_config
sed -i 's/<localRepository>/maven/<localRepository>/maven_repo/g' /data/jenkins/tools/apache-maven-3.6.3/conf/settings.xml

docker run -d --name jenkins \
  -p 8080:8080 \
  --restart=always \
  --net=host \
  -v /data/jenkins/jenkins_home:/var/jenkins_home \
  -v /data/jenkins/tools:/var/tools \
  -v /etc/ssh/ssh_config:/etc/ssh/ssh_config \
  -v /data/jenkins/maven_repo:/maven_repo \
  -v /data/jenkins/.ssh:/var/jenkins_home/.ssh \
  -v /data/jenkins/.npmrc:/var/jenkins_home/.npmrc \
  $1/jenkins

  #config.yaml 中的内容 用于maven编译配置文件