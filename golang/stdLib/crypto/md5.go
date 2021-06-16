package main

import (
	"crypto/md5"
	"fmt"
)

func main() {
	mymd5 := md5.New() //返回一个新的使用MD5校验的hash.Hash接口
	mymd5.Write([]byte("hello golang"))
	result := mymd5.Sum(nil) //返回数据data的MD5校验和
	fmt.Printf("%x\n\n", result)
}
