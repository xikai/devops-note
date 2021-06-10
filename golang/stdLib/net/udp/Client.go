package main

import (
	"fmt"
	"net"
)

func main() {
	//发起网络连接
	conn, err := net.Dial("udp", "127.0.0.1:8848")
	if err != nil {
		fmt.Println("connect to network faild!")
	}
	defer conn.Close() //延迟关闭连接

	sendMsg := []byte("hello nimei")
	conn.Write(sendMsg)
	fmt.Println("发送消息：", string(sendMsg))

	var recvMsg [30]byte
	conn.Read(recvMsg[0:])
	fmt.Println("收到消息：", string(recvMsg[:]))
}
