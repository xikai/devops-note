package main

import (
	"bytes"
	"fmt"
	"regexp"
)

func main() {
	r, _ := regexp.Compile("p([a-z]+)ch")

	//配置字符串
	fmt.Println(r.MatchString("peach"))   		//true
	fmt.Println(r.Match([]byte("peach")))			//true
	//返回首次匹配正则的字符串
	fmt.Println(r.FindString("peach punch peach"))		//peach
	//查找第一次匹配的字符串的，但是返回的匹配开始和结束位置索引，而不是匹配的内容
	fmt.Println(r.FindStringIndex("peach punch")) //[0 5]
	//Submatch 返回完全匹配和局部匹配的字符串。例如，这里会返回 p([a-z]+)ch 和 `([a-z]+) 的信息
	fmt.Println(r.FindStringSubmatch("peach punch"))		//[peach ea]
	//返回完全匹配和局部匹配的索引位置
	fmt.Println(r.FindStringSubmatchIndex("peach punch"))	//[0 5 1 3]
	//返回匹配正则的所有字符串，而不仅仅是首次匹配
	fmt.Println(r.FindAllString("peach punch pinch", -1)) //[peach punch pinch]
	//返回匹配正则的字符串部分，第二个参数限制匹配次数
	fmt.Println(r.FindAllString("peach punch pinch", 2))	//[peach punch]

	//MustCompile只有一个返回值
	rr := regexp.MustCompile("p([a-z]+)ch")
	fmt.Println(rr)
	//替换匹配字符串
	fmt.Println(rr.ReplaceAllString("a peach", "fruit"))	//a fruit

	in := []byte("a peach")
	//Func 变量允许传递匹配内容到一个给定的函数中
	out := r.ReplaceAllFunc(in, bytes.ToUpper)
	fmt.Println(string(out))	//a PEACH
}