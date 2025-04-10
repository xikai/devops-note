
* https://docs.docker.com/build/architecture/
* https://docs.docker.com/build/building/multi-platform/

# [在内核中使用QEMU仿真支持](https://docs.docker.com/build/building/multi-platform/#qemu)
* QEMU 是一个处理器模拟器，可以模拟不同的 CPU 架构，我们可以把它理解为是另一种形式的虚拟机.在 buildx 中，QEMU 用于在构建过程中执行非本地架构的二进制文件。例如，在 x86 主机上构建一个 ARM 镜像时，QEMU 可以模拟 ARM 环境并运行 ARM 二进制文件。
* binfmt_misc 是 Linux 内核的一个模块，它允许用户注册可执行文件格式和相应的解释器。当内核遇到未知格式的可执行文件时，会使用 binfmt_misc 查找与该文件格式关联的解释器（在这种情况下是 QEMU）并运行文件。
* QEMU 和 binfmt_misc 的结合使得通过 buildx 跨平台构建成为可能。这样我们就可以在一个架构的主机上构建针对其他架构的 Docker 镜像，而无需拥有实际的目标硬件。
>1.如果您的构建器已经支持QEMU，那么在仿真下使用QEMU构建多平台映像是最简单的入门方法,Docker Desktop支持开箱即用.它不需要更改你的Dockerfile，并且BuildKit会自动检测可用的另一种CPU架构.当BuildKit需要为不同的cpu架构运行二进制文件时，它会自动通过在binfmt_misc处理程序中注册的二进制文件加载它.\
>2.使用QEMU进行模拟可能比本地构建慢得多，特别是对于编译、压缩或解压缩等计算量大的任务(如果可能的话，请使用交叉编译替代它)。
```
# 虽然Docker Desktop预先配置了对其他平台的binfmt_misc支持，但对于其他版本 Docker，你可能需要使用 tonistiigi/binfmt 镜像启动一个特权容器来进行支持:
docker run --privileged --rm tonistiigi/binfmt --install all
```



# [使用相同的构建器实例在多个本地节点上构建](https://docs.docker.com/build/building/multi-platform/#multiple-native-nodes)
>使用多个本机节点可以为QEMU无法处理的更复杂的情况提供更好的支持，并且通常具有更好的性能,
```sh
# 假设己经存在node-amd64和node-arm64两台主机
$ docker context ls
NAME                TYPE                DESCRIPTION
node-amd64
node-arm64

# 使用node-amd64主机，创建构建器mybuild
$ docker buildx create --use --name mybuild node-amd64
mybuild

# 可以使用--append标志向构建器实例添加其他节点
$ docker buildx create --append --name mybuild node-arm64

# 构建多平台镜像
$ docker buildx build --platform linux/amd64,linux/arm64 .
```
* [eg: 在 GitHub Actions CI中,使用相同的构建器实例在多个本地节点上构建](https://docs.docker.com/build/ci/github-actions/configure-builder/#append-additional-nodes-to-the-builder)

# [使用Dockerfile中的一个阶段来交叉编译到不同的架构](https://docs.docker.com/build/building/multi-platform/#cross-compilation)
>Dockerfiles中的多阶段构建可以有效地用于使用构建节点的本地架构为目标平台构建二进制文件。BUILDPLATFORM、TARGETOS、TARGETARCH、TARGETPLATFORM 四个变量是 BuildKit 提供的全局变量，分别表示构建镜像所在平台、操作系统、架构、构建镜像的目标平台。\
>通过 --platform 参数传递的 linux/arm64,linux/amd64 镜像目标平台列表会依次传递给 TARGETPLATFORM 变量,而 TARGETOS、TARGETARCH 两个变量在使用时则需要先通过 ARG 进行声明，BuildKit 会自动为其赋值
```sh
# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM golang:alpine AS build
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log
FROM alpine
COPY --from=build /log /log
```
```
docker buildx build --platform linux/arm64,linux/amd64 -t xikai/hello-cross-go . --push
```
```
# 启动镜像后输出结果不变：
$ docker run --rm xikai/hello-cross-go
Hello, linux/arm64!
$ docker run --rm xikai/hello-cross-go
Hello, linux/amd64!
```


# buildx构建多平台镜像
* [使用docker-container驱动程序,创建一个新的构建器](https://docs.docker.com/build/drivers/docker-container/)
>要使用 buildx 构建多平台镜像，我们需要先创建一个 builder。它可以让你访问更复杂的功能，比如多平台构建和更高级的缓存导出器，这些功能目前在默认的docker驱动程序中不支持.
```sh
# 列出己存在的构建器(这将显示默认的内置驱动程序，它使用直接内置到docker引擎中的BuildKit服务器组件，也称为docker驱动程序)
$ docker buildx ls
default                         error
desktop-linux * docker
  desktop-linux desktop-linux   running v0.11.6+0a15675913b7 linux/amd64, linux/amd64/v2, linux/amd64/v3, linux/arm64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/mips64le, linux/mips64, linux/arm/v7, linux/arm/v6
```
```sh
# Docker Desktop的默认构建器不支持构建多平台镜像
$ docker buildx build --platform=linux/amd64,linux/arm64 .
[+] Building 0.0s (0/0)                                                                                                                                    docker:desktop-linux
ERROR: Multiple platforms feature is currently not supported for docker driver. Please switch to a different driver (eg. "docker buildx create --use")
```

```sh
# usage:
$ docker buildx create \
  --name container \
  --driver=docker-container \  #默认为docker-container
  --driver-opt=[key=value,...]

# 创建builder
docker buildx create --name mybuilder --bootstrap --use
#Options:
#      --append                   Append a node to builder instead of changing it
#      --bootstrap                Boot builder after creation
#      --buildkitd-flags string   Flags for buildkitd daemon
#      --config string            BuildKit config file
#      --driver string            Driver to use (available: "cloud", "docker-container", "kubernetes", "remote")
#      --driver-opt stringArray   Options for the driver
#      --leave                    Remove a node from builder instead of changing it
#      --name string              Builder instance name
#      --node string              Create/modify node with given name
#      --platform stringArray     Fixed platforms for current node
#      --use                      Set the current builder instance

# 删除 builder
docker buildx rm mybuilder
```


* 测试工作流以确保您可以构建、推送和运行多平台映像。创建一个简单的示例Dockerfile，构建两个镜像变体，并将它们推送到Docker Hub
```sh
# syntax=docker/dockerfile:1
FROM alpine:3.16
RUN apk add curl
```
```sh
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t <username>/<image>:latest --push .
# --platform 通知buildx为AMD 64位、Arm 64位和Armv7架构创建Linux映像
# --push 生成一个多arch清单，并将所有的映像推送到Docker Hub
# --load 将多平台镜像加载到本地（不支持直接将多平台镜像输出到本机，这其实是因为传递了多个 --platform 的关系）
```

* 查看镜像信息
```sh
$ docker buildx imagetools inspect <username>/<image>:latest
Name:      docker.io/<username>/<image>:latest
MediaType: application/vnd.docker.distribution.manifest.list.v2+json
Digest:    sha256:f3b552e65508d9203b46db507bb121f1b644e53a22f851185d8e53d873417c48

Manifests:
  Name:      docker.io/<username>/<image>:latest@sha256:71d7ecf3cd12d9a99e73ef448bf63ae12751fe3a436a007cb0969f0dc4184c8c
  MediaType: application/vnd.docker.distribution.manifest.v2+json
  Platform:  linux/amd64

  Name:      docker.io/<username>/<image>:latest@sha256:5ba4ceea65579fdd1181dfa103cc437d8e19d87239683cf5040e633211387ccf
  MediaType: application/vnd.docker.distribution.manifest.v2+json
  Platform:  linux/arm64

  Name:      docker.io/<username>/<image>:latest@sha256:29666fb23261b1f77ca284b69f9212d69fe5b517392dbdd4870391b7defcc116
  MediaType: application/vnd.docker.distribution.manifest.v2+json
  Platform:  linux/arm/v7
```

* 使用digest摘要标识一个完全限定的图像变体。您还可以在Docker Desktop上运行针对不同架构的映像。
```sh
$ docker run --rm docker.io/<username>/<image>:latest@sha256:2b77acdfea5dc5baa489ffab2a0b4a387666d1d526490e31845eb64e3e73ed20 uname -m
aarch64

docker run --rm docker.io/<username>/<image>:latest@sha256:723c22f366ae44e419d12706453a544ae92711ae52f510e226f6467d8228d191 uname -m
armv7l
```
>Docker Desktop提供了binfmt_misc多体系结构支持，这意味着您可以在不同的Linux体系结构(如arm、mips、ppc64le甚至s390x)上运行容器。这并不需要在容器本身中进行任何特殊配置，因为它使用来自Docker桌面虚拟机的qemu-static。因此，您可以运行ARM容器，例如busybox映像的arm32v7或ppc64le变体

* 转存多架构镜像
```
# 创建 Dockerfile
echo -e "FROM registry.k8s.io/dns/k8s-dns-node-cache:1.23.1" > Dockerfile
```
```
# 使用 docker buildx build 来构建和推送多架构镜像
docker buildx build --platform linux/amd64,linux/arm64 --pull -t vevorsz/k8s-dns-node-cache:1.23.1 --push .
```