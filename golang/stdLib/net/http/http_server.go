package main

import "net/http"

func sayHello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("hello golang"))
}

func main() {
	http.HandleFunc("/hello", sayHello)
	//开启服务器
	http.ListenAndServe("127.0.0.1:8080", nil)
}

//浏览器访问 http://127.0.0.1:8080/hello
