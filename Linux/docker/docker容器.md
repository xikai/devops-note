```
#基于centos镜像创建并启动容器，运行/bin/bash命令
#创建交互式容器 -i让容器的标准输入保持打开，-t分配一个伪终端并绑定到容器标准输入上，
docker run -i -t centos /bin/bash
#创建守护式容器 -d让容器在后台运行，--name指定容器名(容器名必须唯一，如不指定，docker将会自动生产随机名),--restart=always(无论容器退出码是什么都会自动重启容器)            
docker run -d --name container_name centos
```

* 查看容器
```
#列出所有容器
docker ps -a
#列出exited状态的容器
docker ps -a -f status=exited 
```

* 启动、重启容器
```
docker start 04224b4b2
docker restart container_name
```

* 终止容器
```
docker stop 04224b4b2 
```

* 进入容器
```
docker exec -it 2d951be7bf4c /bin/bash
```

* 退出容器
```
exit或Ctrl+d
```

* 查看容器输出日志(-f 监控日志 -t为每条日志加上时间)
```
docker logs -tf container_name
docker logs --tail 10 container_name   #获取最后10行输出日志
```

* 查看容器内部进程
```
docker top container_name
```

* 在容器上执行命令
```
docker exec -it 2d951be7bf4c /bin/echo "hello world"
```

* 更新容器配置
```
docker update --restart=always container1 container2 container3
```

* 拷贝文件到容器
```
docker cp php-fpm container_name:/usr/local/src
docker cp container_name:/usr/local/src/php-fpm .
```

* 导出容器
```
docker export 2d951be7bf4c > test_for_run.tgz
```

* 导入容器
```
docker import test_for_run.tgz centos:7
```

* 删除容器
```
docker rm 4273769dae71
docker rm -f 4273769dae71                       # 强行删除正在运行的容器
docker rm $(docker ps -a -q -f status=exited)   # 删除exited状态的容器
docker rm $(docker ps -a -q)                    # 删除所有的容器
```


* 查看所有容器对应的pid,name,workDir
```
docker ps -q | xargs docker inspect --format '{{.State.Pid}}, {{.Name}}, {{.GraphDriver.Data.WorkDir}}' 
```