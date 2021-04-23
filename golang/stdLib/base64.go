package main

import b64 "encoding/base64"
import "fmt"

func main() {
	data := "abc123!?$*&()'-=@~"

	sEnc := b64.StdEncoding.EncodeToString([]byte(data))	//base64编码，编码需要使用 []byte 类型的参数
	fmt.Println(sEnc)

	sDec, _ := b64.StdEncoding.DecodeString(sEnc)			//base64解码
	fmt.Println(string(sDec))
}