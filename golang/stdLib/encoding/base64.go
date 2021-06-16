package main

import (
	"encoding/base64"
	"fmt"
)

const base64Table = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm0123456789*/"

var coder = base64.NewEncoding(base64Table)

func base64encode(src []byte) []byte { //编码
	return []byte(coder.EncodeToString(src))
}

func base64decode(src []byte) ([]byte, error) { //解码
	return coder.DecodeString(string(src))
}

func main() {
	fmt.Println(len(base64Table))
	mystr := "hello gogoto"
	debyte := base64encode([]byte(mystr))
	enbyte, err := base64decode(debyte)
	if err != nil {
		fmt.Println("ERROR", err.Error())
	}
	fmt.Println(mystr)
	fmt.Println(string(debyte))
	fmt.Println(string(enbyte))
}
