#!/bin/sh
#
# 更新部署tomcat项目
# time: 2016.02.29
# by: xikai
#

project=$1
port=$2
pidlist=`ps -ef|grep tomcat-$project|egrep -v "\<grep\>|\<tail\>" |awk '{print $2}'`
usage="Usage: $0 {project_name} {port}"


#stop project
project_stop()
{
  if [ "$pidlist" = "" ] ;then
    echo "no tomcat pid alive!"
  else
    echo "tomcat Id list :$pidlist"
    kill -9 $pidlist
    echo "KILL $pidlist:"
    echo "service stop success"
  fi
}

#update project
project_update()
{
  rm -rf /data/www/$project/*
  unzip -o /data/war/$project.war -d /data/www/$project/ >/dev/null
}


#check project
project_check()
{
  code=`/usr/bin/curl -IXGET -o /dev/null -s -w '%{http_code}' http://127.0.0.1:$port/test`
  if [[ $code -ne 200 ]] ;then
    echo "[ERROR] tomcat startup failed."
    exit 1
  fi
}

#exec script
if [[ $# == 2 ]] ;then
  project_stop
  project_update
  rm -rf /usr/local/tomcat-$project/work
  systemctl start tomcat-$project
  sleep 20
  project_check
else
  echo $usage
  exit 1
fi
