package main

import (
	"fmt"
	"net"
)

func checkError(err error) {
	if err != nil {
		fmt.Println("网络错误:", err.Error())
	}
}

func main() {
	conn, err := net.Dial("tcp", "127.0.0.1:8898") //连接tcp服务器
	checkError(err)
	defer conn.Close()

	sendMsg := []byte("hello nimei")
	conn.Write(sendMsg)
	fmt.Println("发送消息：", string(sendMsg))
}
