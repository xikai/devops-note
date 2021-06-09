package main

import (
	"fmt"
	"sort"
)

type ByLength []string
func (s ByLength) Len() int {	//返回长度
	return len(s)
}
func (s ByLength) Swap(i, j int) {	//交换
	s[i], s[j] = s[j], s[i]
}
func (s ByLength) Less(i, j int) bool  { //比较大小
	return len(s[i]) < len(s[j])
}


func main() {
	num := []int{1, 9, 2, 8, 3, 7, 6, 4, 5}
	issort := sort.IntsAreSorted(num)   //判断整数是否排序
	fmt.Println(issort)	//false
	sort.Ints(num)		//整数排序
	fmt.Println(num)	//[1 2 3 4 5 6 7 8 9]

	str := []string{"v", "c", "a", "z"}
	sort.Strings(str)	//字符串排序
	fmt.Println(str)	//[a c v z]

	//自定义排序
	names := []string{"v1", "c123", "a12312", "z123123123"}
	sort.Sort(ByLength(names))
	fmt.Println(names)

}