### 安装golang
```
wget https://golang.org/dl/go1.15.7.darwin-amd64.pkg
#该软件包会将Go安装到 /usr/local/go 目录。 该安装包会将 /usr/local/go/bin 添加到您的 PATH 环境变量中。 您可能需要重新启动您所有打开的终端程序来使其生效

go version
```
```
GOROOT和GOPATH都是环境变量，其中GOROOT是我们安装go开发包的路径，而从Go 1.8版本开始，Go开发包在安装完成后会为GOPATH设置一个默认目录,并且默认情况下 GOROOT下的bin目录及GOPATH下的bin目录都已经添加到环境变量中了，我们也不需要额外配置了
Windows	%USERPROFILE%/go	C:\Users\用户名\go
Unix	$HOME/go	        /home/用户名/go
```

### GOPROXY
* 解决go包管理代理网址无法访问：proxy.golang.org
>Go1.14版本之后，都推荐使用go mod模式来管理依赖环境了，也不再强制我们把代码必须写在GOPATH下面的src目录了，你可以在你电脑的任意位置编写go代码。默认GoPROXY配置是：GOPROXY=https://proxy.golang.org,direct，由于国内访问不到https://proxy.golang.org，所以我们需要换一个PROXY，这里推荐使用https://goproxy.io或https://goproxy.cn。
```sh
#可以执行下面的命令修改GOPROXY：
go env -w GOPROXY=https://goproxy.io,direct

## 永久生效
# 设置你的 bash 环境变量
echo "export GOPROXY=https://goproxy.io,direct" >> ~/.bash_profile && source ~/.bash_profile

# 如果你的终端是 zsh，使用以下命令
echo "export GOPROXY=https://goproxy.io,direct" >> ~/.zshrc && source ~/.zshrc
```

### go module
>go module是Go1.11版本之后官方推出的版本管理工具，并且从Go1.13版本开始，go module将是Go语言默认的依赖管理工具。
```
要启用go module支持首先要设置环境变量GO111MODULE，通过它可以开启或关闭模块支持，它有三个可选值：off、on、auto，默认值是auto。

GO111MODULE=off禁用模块支持，编译时会从GOPATH和vendor文件夹中查找包。
GO111MODULE=on启用模块支持，编译时会忽略GOPATH和vendor文件夹，只根据 go.mod下载依赖。
GO111MODULE=auto，当项目在$GOPATH/src外且项目根目录有go.mod文件时，开启模块支持。
简单来说，设置GO111MODULE=on之后就可以使用go module了，以后就没有必要在GOPATH中创建项目了，并且还能够很好的管理项目依赖的第三方包信息。

使用 go module 管理依赖后会在项目根目录下生成两个文件go.mod和go.sum。
```
* go mod命令
```
go mod download    下载依赖的module到本地cache（默认为$GOPATH/pkg/mod目录）
go mod edit        编辑go.mod文件
go mod graph       打印模块依赖图
go mod init        初始化当前文件夹, 创建go.mod文件
go mod tidy        增加缺少的module，删除无用的module
go mod vendor      将依赖复制到vendor下
go mod verify      校验依赖
go mod why         解释为什么需要依赖
```

* go.mod文件记录了项目所有的依赖信息，其结构大致如下：
```
module github.com/Q1mi/studygo/blogger

go 1.12

require (
	github.com/DeanThompson/ginpprof v0.0.0-20190408063150-3be636683586
	github.com/gin-gonic/gin v1.4.0
	github.com/go-sql-driver/mysql v1.4.1
	github.com/jmoiron/sqlx v1.2.0
	github.com/satori/go.uuid v1.2.0
	google.golang.org/appengine v1.6.1 // indirect
)
```

### 命令行运行golang
* 创建项目目录
```
cd
mkdir hello
cd hello
```
* 编写go 示例代码
>vim hello.go
```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
```
* 命令行运行
```
 11:47 $ go run hello.go
Hello, World!
```

### 配置vscode
* 安装go扩展工具(国内设置GOPROXY代理：https://goproxy.io,direct)
>command+shift+P -> Go:Install/Update Tools -> 选择要安装的命令 -> OK
```
Tools environment: GOPATH=/Users/xik/go
Installing 9 tools at /Users/xik/go/bin in module mode.
  gopkgs
  go-outline
  gotests
  gomodifytags
  impl
  goplay
  dlv
  golint
  gopls

Installing github.com/uudashr/gopkgs/v2/cmd/gopkgs (/Users/xik/go/bin/gopkgs) SUCCEEDED
Installing github.com/ramya-rao-a/go-outline (/Users/xik/go/bin/go-outline) SUCCEEDED
Installing github.com/cweill/gotests/... (/Users/xik/go/bin/gotests) SUCCEEDED
Installing github.com/fatih/gomodifytags (/Users/xik/go/bin/gomodifytags) SUCCEEDED
Installing github.com/josharian/impl (/Users/xik/go/bin/impl) SUCCEEDED
Installing github.com/haya14busa/goplay/cmd/goplay (/Users/xik/go/bin/goplay) SUCCEEDED
Installing github.com/go-delve/delve/cmd/dlv (/Users/xik/go/bin/dlv) SUCCEEDED
Installing golang.org/x/lint/golint (/Users/xik/go/bin/golint) SUCCEEDED
Installing golang.org/x/tools/gopls (/Users/xik/go/bin/gopls) SUCCEEDED

All tools successfully installed. You are ready to Go :).
```

* vscode安装code runner扩展工具
