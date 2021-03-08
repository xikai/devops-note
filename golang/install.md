### 安装golang
```
wget https://golang.org/dl/go1.15.7.darwin-amd64.pkg
#该软件包会将Go安装到 /usr/local/go 目录。 该安装包会将 /usr/local/go/bin 添加到您的 PATH 环境变量中。 您可能需要重新启动您所有打开的终端程序来使其生效

go version
```

### 解决go包管理代理网址无法访问：proxy.golang.org
```sh
## 临时生效(Go 1.13之后，无需再通过设置系统环境变量的方式来修改，可以通过go env -w 命令来设置Go的环境变量)
go env -w GOPROXY=https://goproxy.io,direct

## 永久生效
# 设置你的 bash 环境变量
echo "export GOPROXY=https://goproxy.io,direct" >> ~/.bash_profile && source ~/.bash_profile

# 如果你的终端是 zsh，使用以下命令
echo "export GOPROXY=https://goproxy.io,direct" >> ~/.zshrc && source ~/.zshrc
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
