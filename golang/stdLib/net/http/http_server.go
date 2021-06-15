package main

import "net/http"

func main() {
	http.HandleFunc("/hello",
		func(w http.ResponseWriter, r *http.Request) {
			w.Write([]byte("hello golang"))
		}) //设置服务器返回信息
	http.ListenAndServe("127.0.0.1:8080", nil) //开启服务器
}

//浏览器访问 http://127.0.0.1:8080/hello
