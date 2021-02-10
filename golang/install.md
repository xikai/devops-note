### 安装golang
```
wget https://golang.org/dl/go1.15.7.darwin-amd64.pkg
#该软件包会将Go安装到 /usr/local/go 目录。 该安装包会将 /usr/local/go/bin 添加到您的 PATH 环境变量中。 您可能需要重新启动您所有打开的终端程序来使其生效

go version
```

### 运行golang
* 创建项目目录
```
cd
mkdir hello
cd hello
```
* 编写go 示例代码
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



* 解决go包管理代理网址无法访问：proxy.golang.org
```sh
go env -w GOPROXY=https://goproxy.io,direct

## 永久生效
# 设置你的 bash 环境变量
echo "export GOPROXY=https://goproxy.io,direct" >> ~/.bash_profile && source ~/.bash_profile

# 如果你的终端是 zsh，使用以下命令
echo "export GOPROXY=https://goproxy.io,direct" >> ~/.zshrc && source ~/.zshrc
```