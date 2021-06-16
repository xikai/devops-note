package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"os"
)

func hashsha256file(filepath string) (string, error) {
	var hashvalue string //返回哈希字符串
	file, err := os.Open(filepath)
	if err != nil {
		return hashvalue, err //返回错误，文件打开失败，哈希为空
	}
	defer file.Close()

	myhash := sha256.New() //创建哈希算法对象
	if _, err := io.Copy(myhash, file); err != nil {
		return hashvalue, err //处理拷贝错误
	}
	hashinbytes := myhash.Sum(nil)
	hashvalue = hex.EncodeToString(hashinbytes)
	return hashvalue, nil
}

func main() {
	filepath := "xxx.txt"
	if hash, err := hashsha256file(filepath); err != nil {
		fmt.Printf("%s sha256hash is %s", filepath, hash)
	} else {
		fmt.Printf("%s sha256hash is %s", filepath, hash)
	}
}
