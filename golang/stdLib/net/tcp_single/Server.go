package main

import (
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

func processMsg(conn net.Conn) {
	buf := make([]byte, 1024) //开创缓冲区
	defer conn.Close()
	for {
		numOfBytes, err := conn.Read(buf) //读取缓冲区数据
		if err != nil {
			break
		}
		if numOfBytes != 0 {
			remoteAddr := conn.RemoteAddr()
			fmt.Printf("收到%v的消息：%s\n", remoteAddr, string(buf))
		}
	}
}

func main() {
	listen_socket, err := net.Listen("tcp", "127.0.0.1:8898") //开启tcp服务器监听
	checkError(err)
	defer listen_socket.Close() //关闭监听

	fmt.Println("服务器正在等待连接...")
	for {
		conn, err := listen_socket.Accept() //新的客户端连接
		checkError(err)
		//处理每一个客户端
		go processMsg(conn)
	}

}
