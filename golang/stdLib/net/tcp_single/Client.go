package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
)

func checkError(err error) {
	if err != nil {
		fmt.Println("网络错误:", err.Error())
		os.Exit(1)
	}
}

func sendMsg(conn net.Conn) {
	var input string
	for {
		reader := bufio.NewReader(os.Stdin) //读出键盘输入
		data, _, _ := reader.ReadLine()     //读取一行
		input = string(data)                //键盘输入转化为字符串

		if input == "exit" {
			conn.Close()
			fmt.Println("客户端关闭")
			break
		}

		_, err := conn.Write([]byte(input)) //输入写入字符串
		if err != nil {
			conn.Close()
			fmt.Println("客户端关闭")
			break
		}
	}

}

func main() {
	conn, err := net.Dial("tcp", "127.0.0.1:8898") //连接tcp服务器
	checkError(err)
	defer conn.Close()
	go sendMsg(conn) //开启一个协程

	//协程，负责收取消息
	buf := make([]byte, 1024)
	for {
		numOfBytes, err := conn.Read(buf)
		checkError(err)
		fmt.Println("收到服务器消息", string(buf[:numOfBytes]))
	}
}
