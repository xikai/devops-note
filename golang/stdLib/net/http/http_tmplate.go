package main

import (
	"fmt"
	"html/template"
	"net/http"
)

func sayHello(w http.ResponseWriter, r *http.Request) {
	//1.定义模板文件,在当前路径创建hello.tmpl模板文件
	/*
		<!DOCTYPE html>
		<html lang="zh-CN">
		<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta http-equiv="X-UA-Compatible" content="ie=edge">
		<title>Hello</title>
		</head>
		<body>
		<p>Hello {{.}}</p>
		</body>
		</html>

	*/

	//2.解析模板
	t, err := template.ParseFiles("./hello.tmpl") // 解析指定文件生成模板对象
	if err != nil {
		fmt.Println("Parse template failed, err:%v", err)
		return
	}

	//3.渲染模板
	err = t.Execute(w, "小王子") // 利用给定数据渲染模板，并将结果写入w
	if err != nil {
		fmt.Println("render template failed, err:%v", err)
		return
	}
}

func main() {
	http.HandleFunc("/", sayHello)
	err := http.ListenAndServe(":9000", nil)
	if err != nil {
		fmt.Println("HTTP server start failed, err:%v", err)
		return
	}
}
