package main

import (
	"crypto/sha256"
	"fmt"
)

func main() {
	mystr := "sha256 hello golang"
	mysha256 := sha256.New()      //创建sha256加密算法对象（也可以用sha512）
	mysha256.Write([]byte(mystr)) //写入要散列处理的数据
	result := mysha256.Sum(nil)   //结果计算
	fmt.Printf("%x\n", result)
}
