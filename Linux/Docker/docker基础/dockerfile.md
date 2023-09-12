* https://docs.docker.com/engine/reference/builder/#cmd
* https://docs.docker.com/engine/reference/builder/#entrypoint

# CMD 用于定义容器启动时要执行的默认命令 如：启动主进程
* exec格式, 推荐的写法
>它使用 JSON 数组或类似数组的格式来指定要执行的命令和参数。这样可以避免由于使用 shell 解释器而引起的一些问题，比如参数处理不正确等。
```sh
# CMD ["executable","param1","param2"]
CMD ["nginx", "-g", "daemon off;"]
```
* shell格式
```sh
# CMD command param1 param2
CMD nginx -g "daemon off;"
```

* CMD 指令可以被在运行容器时传递的命令行参数覆盖。这意味着，如果在运行容器时提供了自定义的命令，它将取代 Dockerfile 中定义的默认命令。
```sh
# 例如，如果你有一个 Dockerfile，内容如下：
FROM ubuntu:latest
CMD ["echo", "Hello, Docker!"]
```
```sh
# 当你运行容器时，可以像这样覆盖默认命令, 这将会运行 ls -la 命令而不是默认的 echo 命令
docker run <image_name> ls -la
```

# ENTRYPOINT 用于传递额外的命令行参数启动容器主进程
>可以传递额外的命令行参数，或者希望将容器作为一个可执行的“工具”来运行不同的命令，使用 ENTRYPOINT
* exec格式, 推荐的写法
```sh
# ENTRYPOINT ["executable", "param1", "param2"]
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```
* shell格式
```sh
# ENTRYPOINT command param1 param2
ENTRYPOINT nginx -g "daemon off;"
```

* 如果在 Dockerfile 中已经使用了 ENTRYPOINT 指令，那么 CMD 中的内容会被当作参数传递给 ENTRYPOINT 指定的命令
```
ENTRYPOINT ["/bin/echo"] 
CMD ["this is a test"]
docker run -it imageecho 输出"this is a test"（执行/bin/echo "this is a test"）
```

* --entrypoint参数也会覆盖ENTRYPOINT，否则 docker run参数会追加到ENTRYPOINT后面
```
FROM ubuntu:trusty
ENTRYPOINT ping localhost
```
```
$ docker run --entrypoint hostname <image_name>
075a2fa95ab7
```

* 当你运行容器时，无法覆盖 ENTRYPOINT，但可以传递额外的参数
```
FROM ubuntu:latest
ENTRYPOINT ["echo", "Hello, Docker!"]
```
```sh
docker run <image_name> "Additional text."
# 输出 "Hello, Docker! Additional text."
```