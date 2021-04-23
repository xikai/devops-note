package main

import (
	crand "crypto/rand"
	"fmt"
	"math/big"
	mrand "math/rand"
	"time"
)

func main() {
	// math/rand 伪随机
	// 伪随机生成的数字是确定的，不论在什么机器、什么时间，只要执行的随机代码一样，那么生成的随机数就一样
	fmt.Println(mrand.Intn(10))	//生成一个10以内的整数，多次运行返回相同数字

	mrand.Seed(time.Now().Unix())	//为生成器提供不同的种子数
	fmt.Println(mrand.Intn(10))	//返回10以内的随机数，每次返回值不同

	// crypto/rand 真随机, 是为了提供更好的随机性满足密码对随机数的要求
	for i := 0; i < 4; i++  {
		n, _ := crand.Int(crand.Reader, big.NewInt(100))
		println(n.Int64())
	}
}

//对于不涉及到密码类的开发工作直接使用math/rand+基于时间戳的种子rand.Seed(time.Now().UnixNano())一般都能满足需求
//对于涉及密码类的开发工作一定要用crypto/rand
//如果想生成随机字符串，可以先列出字符串，然后基于随机数选字符的方式实现