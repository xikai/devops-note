package main

import (
	"fmt"
	"strings"
)

func main() {
	fmt.Println(strings.Compare("a", "b"))	//按字典顺序比较两个字符串,返回一个整数
	fmt.Println(strings.Contains("seafood", "foo"))	//判断s是否包含substr
	fmt.Println(strings.ContainsAny("failure", "ux"))	//判断字符串s是否包含字符串chars中的任一字符
	fmt.Println(strings.HasPrefix("dadiyunwu","dadi"))		//判断是否以某字符串开头 
	fmt.Println(strings.HasSuffix("dadiyunwu","yunwu"))		//判断是否以某字符串结尾
	fmt.Println(strings.Count("cheese", "e"))	//返回字符串s中有几个不重复的sep子串。
	fmt.Println(strings.Count("five", ""))	// before & after each rune
	fmt.Println(strings.Index("chicken", "ken")) //索引返回 s 中第一个 substr 实例的索引，如果 substr 不存在于 s 中，则返回-1
	fmt.Println(strings.IndexByte("golang", 'g')) 	//索引返回 s 中第一个byte实例的索引，如果byte实例的索引不存在于 s 中，则返回-1

	fmt.Println("ba" + strings.Repeat("na", 2))	//banana, Repeat返回一个由字符串 s 的计数副本组成的新字符串
	fmt.Println(strings.Split("a,b,c", ","))		//将切片分割成由 sep 分隔的所有子字符串，返回子切片片段
	fmt.Println(strings.Title("her royal highness"))		//返回字符串，将单词首字母大写
	fmt.Println(strings.ToLower("Gopher"))	//gopher，将字符串转换为小写
	fmt.Println(strings.ToUpper("Gopher"))	//GOPHER，将字符串转换为大写
	fmt.Println(strings.Replace("oink oink oink", "k", "ky", 2))	//替换s中前n个old为new

	fmt.Println(strings.TrimLeft("---Achtung!!!", "-"))	//删除字符串左边的指定字符
	fmt.Println(strings.TrimRight("---Achtung!!!", "!"))	//删除字符串右边的指定字符
	fmt.Println(strings.Trim("---Achtung---", "-"))		//删除字符串左右两边的指定字符
	fmt.Println(strings.TrimPrefix("hi hello world bye", "hi"))	//删除s头部的prefix字符串。如果s不是以prefix开头，则返回原始s
	fmt.Println(strings.TrimSuffix("hi hello world bye", "bye"))	//删除s尾部的Suffix字符串。如果s不是以Suffix结尾，则返回原始s
	fmt.Println(strings.TrimSpace(" \t\n a lone gopher \n\t\r\n"))	//删除所有前导和尾部空白

	s := []string{"foo", "bar", "baz"}
	fmt.Println(strings.Join(s, ", "))	 //foo, bar, baz  通过sep分隔符连接字符串切片s中元素

	r := strings.NewReader("some io.Reader stream to be read\n")	//NewReader创建一个从字符串s读取数据的Reader
	r.Len()		//Len 返回字符串未读部分的字节数
	r.Read(b []byte)
	r.ReadByte()

	io.Copy(os.Stdout, r)	//some io.Reader stream to be read, 将字符串输出拷贝到标准输出



}