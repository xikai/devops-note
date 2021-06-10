package main

import (
	"fmt"
	"net"
	"os"
)

//定义一个错误处理函数
func checkError(err error) {
	if err != nil {
		fmt.Println("ERROR:", err.Error())
		os.Exit(1)
	}
}

//接收消息函数
func recvUPDMsg(conn *net.UDPConn) {
	var buf [30]byte
	n, raddr, err := conn.ReadFromUDP(buf[0:]) //从udp接收数据，读取了n个字节
	if err != nil {
		fmt.Println("ERROR:", err.Error())
		return
	}
	fmt.Println("消息：", string(buf[0:n]))
	_, err = conn.WriteToUDP([]byte("hao nimei"), raddr) //写入UDP，根据地址发送
}

func main() {
	//创建UDP服务器
	udp_addr, err := net.ResolveUDPAddr("udp", ":8848")
	checkError(err)

	conn, err := net.ListenUDP("udp", udp_addr) //监听
	defer conn.Close()
	checkError(err)
	recvUPDMsg(conn) //接收消息
}
