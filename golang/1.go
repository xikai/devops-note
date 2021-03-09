25 个关键字或保留字：
	break		default			func	interface	select
	case		defer			go		map			struct
	chan		else			goto	package		switch
	const		fallthrough		if		range		type
	continue	for				import	return		var


36 个预定义标识符:
	append	bool	byte	cap	close	complex	complex64	complex128	uint16
	copy	false	float32	float64	imag	int	int8	int16	uint32
	int32	int64	iota	len	make	new	nil	panic	uint64
	print	println	real	recover	string	true	uint	uint8	uintptr


// 单行注释
/*
	多行
	注释
*/


常量
	/*
	const identifier [type] = value
	显式类型定义： const b string = "abc"
	隐式类型定义： const b = "abc"
	*/
	const Pi = 3.14159
	const beef, two, c = "eat", 2, "veg"
	const Monday, Tuesday, Wednesday, Thursday, Friday, Saturday = 1, 2, 3, 4, 5, 6
	const (
		Monday, Tuesday, Wednesday = 1, 2, 3
		Thursday, Friday, Saturday = 4, 5, 6
	)
	//第一个 iota 等于 0，每当 iota 在新的一行被使用时，它的值都会自动加 1，并且没有赋值的常量默认会应用上一行的赋值表达式：
	// 赋值一个常量时，之后没赋值的常量都会应用上一行的赋值表达式
	const (
		a = iota  // a = 0
		b         // b = 1
		c         // c = 2
		d = 5     // d = 5   
		e         // e = 5
	)


变量
	//var identifier [type] = value
	var a int = 15
	var i = 5
	var b bool = false
	var str string = "Go says hello to the world!"

	func main()  {
		c := 10
		a = 10
	}


指针
	//一个指针变量可以指向任何一个值的内存地址。
	//当一个指针被定义后没有分配到任何变量时，它的默认值为 nil。指针变量通常缩写为 ptr。
	//ptr := &v    // v 的类型为 T,其中 v 代表被取地址的变量，变量 v 的地址使用变量 ptr 进行接收，ptr 的类型为*T，称做 T 的指针类型，*代表指针。
	// & 取出地址，* 根据地址取出地址指向的值
	package main
	import (
		"fmt"
	)
	func main() {
		// 准备一个字符串类型
		var house = "Malibu Point 10880, 90265"
		// 对字符串取地址, ptr类型为*string
		ptr := &house
		// 打印ptr的类型
		fmt.Printf("ptr type: %T\n", ptr)
		// 打印ptr的指针地址
		fmt.Printf("address: %p\n", ptr)
		// 对指针进行取值操作
		value := *ptr
		// 取值后的类型
		fmt.Printf("value type: %T\n", value)
		// 指针取值后就是指向变量的值
		fmt.Printf("value: %s\n", value)
	}

	运行结果：
	ptr type: *string
	address: 0xc0420401b0
	value type: string
	value: Malibu Point 10880, 90265


数据类型
	//布尔类型 bool
	var b bool = true

	//整型 int 和浮点型 float
	//int 和 uint 在 32 位操作系统上，它们均使用 32 位（4 个字节），在 64 位操作系统上，它们均使用 64 位（8 个字节)
	//整数：
	int8（-128 -> 127）
	int16（-32768 -> 32767）
	int32（-2,147,483,648 -> 2,147,483,647）
	int64（-9,223,372,036,854,775,808 -> 9,223,372,036,854,775,807）
	//无符号整数：
	uint8（0 -> 255）
	uint16（0 -> 65,535）
	uint32（0 -> 4,294,967,295）
	uint64（0 -> 18,446,744,073,709,551,615）
	//浮点型（IEEE-754 标准）：
	float32（+- 1e-45 -> +- 3.4 * 1e38）
	float64（+- 5 * 1e-324 -> 107 * 1e308）


	//复数
	complex64 (32 位实数和虚数)
	complex128 (64 位实数和虚数)
	//复数使用 re+imI 来表示，其中 re 代表实数部分，im 代表虚数部分，I 代表根号负 1。
	var c1 complex64 = 5 + 10i
	fmt.Printf("The value is: %v", c1)
	// 输出： 5 + 10i


格式化说明符
	%d 用于格式化整数（%x 和 %X 用于格式化 16 进制表示的数字)
	%g 用于格式化浮点型（%f 输出浮点数，%e 输出科学计数表示法）
	%0nd 用于规定输出长度为n的整数，其中开头的数字 0 是必须的。
	%n.mg 用于表示数字 n 并精确到小数点后 m 位，除了使用 g 之外，还可以使用 e 或者 f，例如：使用格式化字符串 %5.2e 来输出 3.4 的结果为 3.40e+00。
	%b 是用于表示位的格式化标识符	


运算符
	//算术运算符
	+、-、*、/
	-=、*=、/=、%=、++、--

	//逻辑运算符
	==、!=、<、<=、>、>=、&&、||

	//位运算符
	位与 &
	位或 |
	位异或 ^
	位左移 <<
	位右移 >>


流程控制
	//if-else 结构
	if condition1 {
		// do something	
	} else if condition2 {
		// do something else	
	} else {
		// catch-all or default
	}

	if val := 10; val > max {
		// do something
	}

	//switch
	switch var1 {
		case val1:
			...
		case val2:
			...
		default:
			...
	}


	//for
	for i := 0; i < 5; i++ {
		fmt.Printf("This is the %d iteration\n", i)
	}

	//break 语句退出循环
	package main

	func main() {
		for i:=0; i<3; i++ {
			for j:=0; j<10; j++ {
				if j>5 {
				    break   
				}
				print(j)
			}
			print("  ")
		}
	}
	//输出：012345 012345 012345,

	//continue跳过本次循环，继续执行
	package main

	func main() {
		for i := 0; i < 10; i++ {
			if i == 5 {
				continue
			}
			print(i)
			print(" ")
		}
	}
	//输出：0 1 2 3 4 6 7 8 9 ,5被跳过

	//LABEL: for、switch 或 select 语句都可以配合标签（label）形式的标识符使用，即某一行第一个以冒号（:）结尾的单词
	//continue 语句指向 LABEL1，当执行到该语句的时候，就会跳转到 LABEL1 标签的位置。当 j==4 和 j==5 的时候，没有任何输出
	package main
	import "fmt"

	func main() {
	LABEL1:
		for i := 0; i <= 5; i++ {
			for j := 0; j <= 5; j++ {
				if j == 4 {
					continue LABEL1
				}
				fmt.Printf("i is: %d, and j is: %d\n", i, j)
			}
		}
	}


	//goto 使用标签和 goto 语句是不被鼓励
	package main

	func main() {
		i:=0
		HERE:
			print(i)
			i++
			if i==5 {
				return
			}
			goto HERE
	}
	//输出 01234


函数
	//不带参数的函数
	func f() {
	}

	//带参数的函数，指定参数类型，和返回值类型
	func f(i int) int {
	}

	//传递变长参数的函数,变参函数
	func myFunc(a, b, arg ...int) {
	}

	func Greeting(prefix string, who ...string) {
	}
	Greeting("hello:", "Joe", "Anna", "Eileen")   //变量 who 的值为 []string{"Joe", "Anna", "Eileen"}

	//将函数作为参数，函数可以作为其它函数的参数进行传递，然后在其它函数内调用执行，一般称之为回调
	package main
	import "fmt"

	func main() {
		callback(1, Add)
	}

	func Add(a, b int) {
		fmt.Printf("The sum of %d and %d is: %d\n", a, b, a+b)
	}

	func callback(y int, f func(int, int)) {
		f(y, 2) // this becomes Add(1, 2)
	}
	//输出：The sum of 1 and 2 is: 3

	//函数变量
	//函数也是一种类型，可以和其他类型一样保存在变量中，下面的代码定义了一个函数变量 f，并将一个函数名为 fire()的函数赋给函数变量 f
	package main
	import "fmt"

	func fire() {
	    fmt.Println("fire")
	}
	func main() {
	    var f func()
	    f = fire
	    f()
	}

	//匿名函数，即在需要使用函数时再定义函数，匿名函数没有函数名只有函数体
	//第3行}后的(100)，表示对匿名函数进行调用，传递参数为 100,  输出：hello 100
	func(data int) {
		fmt.Println("hello", data)
	}(100)
	
	//匿名函数可以被赋值于某个变量，即保存函数的地址到变量中
	fplus := func(x, y int) int { return x + y }
	调用匿名函数：fplus(3,4)
	或者直接使用匿名函数：func(x, y int) int { return x + y } (3, 4)

	//匿名函数-闭包
	package main

	func f() func(b int) int {
		return func(b int) int {
			return b
		}
	}

	func main() {
		a := f()
		print(a(5))
	}

	//通过 return 关键字返回一组值，在函数块里面，return 之后的语句都不会执行

	// defer 允许我们推迟到函数返回之前（或任意位置执行 return 语句之后）一刻才执行某个语句或函数
	func function1() {
		fmt.Println("In function1 at the top")
		defer fmt.Println("dddd")
		fmt.Println("In function1 at the bottom")
	}
	function1() 
	//输出：
	In function1 at the top
	In function1 at the bottom
	dddd


数组、切片
	//数组是具有相同 类型唯一 的一组已编号且长度固定的数据项序列
	//数组是 可变的
	var arr1 [5]int
	var arrAge = [5]int{18, 20, 15, 22, 16}

	//在编译期间通过源代码推导数组的大小
	arr1 := [...]int{1, 2, 3} 

	//切片（slice）是对数组一个连续片段的引用（该数组我们称之为相关数组，通常是匿名的），所以切片是一个引用类型
	切片的初始化:
	arr[0:3] or slice[0:3]
	slice := []int{1, 2, 3}
	slice := make([]int, 10)


map
	map 是一种元素对（key values pair）的无序集合,也称为关联数组或字典
	var mapLit map[string]int
	mapLit = map[string]int{"one": 1, "two": 2}

	mapCreated := make(map[string]float32)


结构体（struct）
	//Go语言可以通过自定义的方式形成新的类型，结构体就是这些类型中的一种复合类型，结构体是由零个或多个任意类型的值聚合成的实体，每个值都可以称为结构体的成员。

	/*结构体成员也可以称为“字段”，这些字段有以下特性：
		字段拥有自己的类型和值；
		字段名必须唯一；
		字段的类型也可以是结构体，甚至是字段所在结构体的类型。
	*/
	//定义结构体：
	type T struct {
		a int
		b int
	}

	//必须在定义结构体并实例化后才能使用结构体的字段
	var ms T
	ms.a = 10
	ms.b = 20

	//eg.
	package main
	import "fmt"

	type struct1 struct {
	    i1  int
	    f1  float32
	    str string
	}

	func main() {
	    ms := new(struct1)
	    ms.i1 = 10
	    ms.f1 = 15.5
	    ms.str= "Chris"

	    fmt.Printf("The int is: %d\n", ms.i1)
	    fmt.Printf("The float is: %f\n", ms.f1)
	    fmt.Printf("The string is: %s\n", ms.str)
	    fmt.Println(ms)
	}

	//匿名字段和内嵌结构体 “继承”
	package main

	import "fmt"

	type A struct {
		ax, ay int
	}

	type B struct {
		A
		bx, by float32
	}

	func main() {
		b := B{A{1, 2}, 3.0, 4.0}
		fmt.Println(b.ax, b.ay, b.bx, b.by)
		fmt.Println(b.A)
	}


interface
	//接口可以实现很多面向对象的特性，接口定义了一组方法（方法集），但是这些方法不包含（实现）代码：它们没有被实现（它们是抽象的）。接口里也不能包含变量。
	type Namer interface {
		Method1(param_list) return_type
		Method2(param_list) return_type
		...
	}