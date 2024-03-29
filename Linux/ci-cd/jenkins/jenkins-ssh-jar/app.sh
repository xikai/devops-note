#!/bin/sh
# yum install java-1.8.0-openjdk java-1.8.0-openjdk-devel

set -x

JAR_PATH=$(cd `dirname $0`; pwd)
PARENT_PATH=$(cd `dirname $0`;cd ..; pwd)
JAR_NAME='data-api-server.jar'

get_pid () {
    ps -ef | grep $1 | grep -v "$0" | grep -v "grep" |  awk '{print $2}'
}

stop (){
    ID=`get_pid ${JAR_NAME}`
    echo $JAR_NAME
    echo "stop start....."
    ID=`get_pid ${JAR_NAME}`
    echo "$ID"
    for id in $ID
    do
        kill  $id
        echo "kill $id"
    done
    sleep 15
    PID_COUNT=`get_pid ${JAR_NAME}|wc -l`
    if [ $PID_COUNT = 0 ];then
        echo "stop end....."
    else
	ID=`get_pid ${JAR_NAME}`
	for id in $ID
    	do
           kill -9 $id
           echo "killed $id"
        done
    fi
}


start () {
    ID=`get_pid ${JAR_NAME}`
    echo $ID
    if [ $ID ];then
    	echo "process already run ..."
	echo "exit"
	exit
    fi

    echo "current path ${JAR_PATH}"
    nohup java -Xms6g -Xmx6g -jar -Dspring.profiles.active=prod -d64 ${JAR_PATH}/$JAR_NAME  &> /dev/null &
    sleep 5
    ID=`get_pid ${JAR_NAME}`
    if [ $ID ];then
        echo "success ......"
    fi
    }

case $1 in
    start)
	start
    ;;
    stop)
	stop
    ;;
    restart)
	stop
	start
    ;;
    *)
	echo "Usage: ./$0 start|stop|restart"
    ;;
esac