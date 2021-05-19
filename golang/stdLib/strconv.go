package main

import (
	"fmt"
	"strconv"
)

//strconv包实现了基本数据类型与其字符串表示的转换

func main() {
	//Atoi()函数用于将字符串类型的整数转换为int类型
	s1 := "100"
	i1, _ := strconv.Atoi(s1)
	fmt.Printf("type:%T value:%#v\n", i1, i1)	//type:int value:100

	//Itoa()函数用于将int类型数据转换为对应的字符串表示
	i2 := 200
	s2 := strconv.Itoa(i2)
	fmt.Printf("type:%T value:%#v\n", s2, s2)	//s2 := strconv.Itoa(i2)


	//Parse类函数用于转换字符串为给定类型的值：ParseBool()、ParseFloat()、ParseInt()、ParseUint()
	b, _ := strconv.ParseBool("true")
	f, _ := strconv.ParseFloat("3.1415", 64)
	i, _ := strconv.ParseInt("-2", 10, 64)
	u, _ := strconv.ParseUint("2", 10, 64)
	fmt.Println(b,f,i,u)

	//Format系列函数将给定类型数据格式化为string类型数据
	sf1 := strconv.FormatBool(true)
	sf2 := strconv.FormatFloat(3.1415, 'E', -1, 64)
	sf3 := strconv.FormatInt(-2, 16)
	sf4 := strconv.FormatUint(2, 16)
	fmt.Println(sf1,sf2,sf3,sf4)

}