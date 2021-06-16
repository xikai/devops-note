package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
)

func main() {
	url := "http://www.baidu.com"
	resp, err := http.Get(url)
	//resp, err := http.Post(url,"application/x-www-form-urlencoded",strings.NewReader("id=nimei"))
	if err != nil {
		fmt.Printf("faild, err:%v\n", err)
		return
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("read from resp.Body failed, err:%v\n", err)
		return
	}
	fmt.Print(string(body))
}
