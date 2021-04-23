package main

import (
	"flag"
	"fmt"
	"os"
	"strings"
)

func main() {
	//命令行参数
	fmt.Println(os.Args)		//返回脚本名和参数
	fmt.Println(os.Args[1:])	//返回所有参数
	fmt.Println(os.Args[3])		//返回第三个参数
	/*
	 16:47 $ ./test a b c d
	[./test a b c d]
	[a b c d]
	c
	*/

	//flag.Xxx("参数名","默认值","usage使用方法")
	host := flag.String("host", "127.0.0.1", "请输入host地址")
	port := flag.Int("port", 3306, "请输入端口号")
	flag.Parse() // 解析参数
	fmt.Printf("%s:%d\n", *host, *port)
	/*
		./test -host=10.1.1.1
		10.1.1.1:3306  	//如果不指定参数，则会使用默认值
	*/


	//环境变量
	os.Setenv("PROGRAM","go")		//设置环境变量
	fmt.Println("PROGRAM:", os.Getenv("PROGRAM"))		//获取环境变量

	for _, e := range os.Environ() {	//os.Environ 来列出所有环境变量键值队,返回一个KEY=value 形式的字符串切片
		pair := strings.Split(e, "=")
		fmt.Println(pair[0])	//打印所有key
	}
	
}




