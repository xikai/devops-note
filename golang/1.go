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

变量
	//var identifier [type] = value
	var a int
	var b bool = false
	var str string = "Go says hello to the world!"

	//根据变量值的类型推断变量类型
	var i = 5

	func foo() (int, string) {
		return 10,"golang"
	}

	func main()  {
		a = 15
		//函数内短变量声明
		c := 10

		//匿名变量_
		_,e := foo()
		fmt.Println("c等于：", c)
		fmt.Println("e等于：", e)
	}


常量
	//有时，你需要在代码中加入静态值，这称为 常量
	/*
	const identifier [type] = value
	显式类型定义： const b string = "abc"
	隐式类型定义(根据值推断常量类型)： const b = "abc"
	*/
	const Pi = 3.14159
	const beef, two, c = "eat", 2, "veg"
	const Monday, Tuesday, Wednesday, Thursday, Friday, Saturday = 1, 2, 3, 4, 5, 6
	const (
		Monday, Tuesday, Wednesday = 1, 2, 3
		Thursday, Friday, Saturday = 4, 5, 6
	)

	//常量如果没有附值，则与上一个常量值相同
	const（
		n1 = 10    //n1 = 10
		n2		   //n2 = 10
		n3		   //n3 = 10
	）

	//第一个 iota 等于 0，每当 iota 在新的一行被使用时，它的值都会自动加 1，并且没有赋值的常量默认会应用上一行的赋值表达式：
	//赋值一个常量时，之后没赋值的常量都会应用上一行的赋值表达式
	const (
		a = iota  // a = 0
		b         // b = 1
		c         // c = 2
		d = 5     // d = 5   
		e         // e = 5
	)


基本数据类型
	/*
	Go 有四类数据类型：
		基本类型：数字、字符串和布尔值
		聚合类型：数组和结构
		引用类型：指针、切片、映射、函数和通道
		接口类型：接口
	*/

	//数值（整型 int 和浮点型 float）
	//int 和 uint 在 32 位操作系统上，它们均使用 32 位（4 个字节），在 64 位操作系统上，它们均使用 64 位（8 个字节)
	//在不同类型之间不能执行数学运算，需要强制转换（int 与 int32 不同）
	//整数：
	int8（-128 -> 127）
	int16（-32768 -> 32767）
	int32（-2147483648 -> 2147483647）
	int64（-9223372036854775808 -> 9223372036854775807）
	//无符号整数：
	uint8（0 -> 255）
	uint16（0 -> 65535）
	uint32（0 -> 4294967295）
	uint64（0 -> 18446744073709551615）
	//特殊整型
	uint	32位操作系统上就是uint32，64位操作系统上就是uint64
	int		32位操作系统上就是int32，64位操作系统上就是int64
	//浮点型（IEEE-754 标准）：
	float32（+- 1e-45 -> +- 3.4 * 1e38）
	float64（+- 5 * 1e-324 -> 107 * 1e308）

	//布尔类型 bool
	var b bool = true

	//复数
	complex64 (32 位实数和虚数)
	complex128 (64 位实数和虚数)
	//复数使用 re+imI 来表示，其中 re 代表实数部分，im 代表虚数部分，I 代表根号负 1。
	var c1 complex64 = 5 + 10i
	fmt.Printf("The value is: %v", c1)
	// 输出： 5 + 10i

	//默认值
	func main() {
		var defaultInt int			//0
		var defaultFloat32 float32	//+0.000000e+000
		var defaultFloat64 float64	//+0.000000e+000
		var defaultBool bool		//false
		var defaultString string	//空值
		println(defaultInt, defaultFloat32, defaultFloat64, defaultBool, defaultString)
	}

	//类型转换
	var integer16 int16 = 127
	var integer32 int32 = 32767
	println(int32(integer16) + integer32)


	//格式化说明符，参考fmt包
	%s 用于格式化字符串
	%d 用于格式化整数（%x 和 %X 用于格式化 16 进制表示的数字)
	%g 用于格式化浮点型（%f 输出浮点数，%e 输出科学计数表示法）
	%0nd 用于规定输出长度为n的整数，其中开头的数字 0 是必须的。
	%n.mg 用于表示数字 n 并精确到小数点后 m 位，除了使用 g 之外，还可以使用 e 或者 f，例如：使用格式化字符串 %5.2e 来输出 3.4 的结果为 3.40e+00。
	%b 是用于表示位的格式化标识符
	%T 表示数据类型格式化
	%p 指针（内存地址）	


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

	//类似while,只要 num 变量保存的值与 5 不同，程序就会输出一个随机数
	func main() {
		var num int64
		rand.Seed(time.Now().Unix())
		for num != 5 {
			num = rand.Int63n(15)
			fmt.Println(num)
		}
	}

	//无限循环
	func main() {
		var num int32
		sec := time.Now().Unix()
		rand.Seed(sec)
	
		for {
			fmt.Print("Writting inside the loop...")
			if num = rand.Int31n(10); num == 5 {
				fmt.Println("finish!")
				break
			}
			fmt.Println(num)
		}
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

	//continue跳过本次循环，继续执行（跳过循环的当前迭代）
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


数组
	//数组是同一种数据类型元素的集合。 在Go语言中，数组从声明时就确定，使用时可以修改数组成员，但是数组大小不可变化
	//var 数组变量名 [元素数量]T
	var arr1 [5]int
	var arrAge = [5]int{18, 20, 15, 22, 16}

	//在编译期间通过源代码推导数组的大小
	arr1 := [...]int{1, 2, 3} 

	func main() {
		var testArray [3]int                        //数组会初始化为int类型的零值
		var numArray = [3]int{1, 2}                 //使用指定的初始值完成初始化
		var cityArray = [3]string{"北京", "上海", "深圳"} //使用指定的初始值完成初始化
		fmt.Println(testArray)                      //[0 0 0]
		fmt.Println(numArray)                       //[1 2 0]
		fmt.Println(cityArray)                      //[北京 上海 深圳]
	}

	//遍历数组
	func main() {
		var a = [...]string{"北京", "上海", "深圳"}
		// 方法1：for循环遍历
		for i := 0; i < len(a); i++ {
			fmt.Println(a[i])
		}
	
		// 方法2：for range遍历
		for index, value := range a {
			fmt.Println(index, value)
		}
	}

	//多维数组
	func main() {
		a := [3][2]string{
			{"北京", "上海"},
			{"广州", "深圳"},
			{"成都", "重庆"},
		}
		fmt.Println(a) //[[北京 上海] [广州 深圳] [成都 重庆]]
		fmt.Println(a[2][1]) //支持索引取值:重庆
	}

	//支持的写法，多维数组只有第一层可以使用...来让编译器推导数组长度
	a := [...][2]string{
		{"北京", "上海"},
		{"广州", "深圳"},
		{"成都", "重庆"},
	}
	//不支持多维数组的内层使用...
	b := [3][...]string{
		{"北京", "上海"},
		{"广州", "深圳"},
		{"成都", "重庆"},
	}

	//数组是值类型
	package main

	import "fmt"

	func modifyArray(x [3]int) {
		x[0] = 100
	}

	func modifyArray2(x [3][2]int) {
		x[2][0] = 100
	}
	func main() {
		a := [3]int{10, 20, 30}
		modifyArray(a) //在modify中修改的是a的副本x
		fmt.Println(a) //[10 20 30]
		b := [3][2]int{
			{1, 1},
			{1, 1},
			{1, 1},
		}
		modifyArray2(b) //在modify中修改的是b的副本x
		fmt.Println(b)  //[[1 1] [1 1] [1 1]]
	}


切片
	//切片（slice）是对数组一个连续片段的引用（该数组我们称之为相关数组，通常是匿名的），所以切片是一个引用类型
	//切片的初始化:
	arr[0:3] or slice[0:3]
	slice := []int{1, 2, 3}

	a[2:]  // 等同于 a[2:len(a)]
	a[:3]  // 等同于 a[0:3]
	a[:]   // 等同于 a[0:len(a)]

	//使用make()函数构造切片 make([]T, size, cap)
	slice := make([]int, 3)  //[0 0 0]

	//append()添加元素
	func main(){
		var s []int
		s = append(s, 1)        // [1]
		s = append(s, 2, 3, 4)  // [1 2 3 4]
		s2 := []int{5, 6, 7}  
		s = append(s, s2...)    // [1 2 3 4 5 6 7]
	}

	//由于切片是引用类型，所以a和b其实都指向了同一块内存地址。修改b的同时a的值也会发生变化。
	func main() {
		a := []int{1, 2, 3, 4, 5}
		b := a
		fmt.Println(a) //[1 2 3 4 5]
		fmt.Println(b) //[1 2 3 4 5]
		b[0] = 1000
		fmt.Println(a) //[1000 2 3 4 5]
		fmt.Println(b) //[1000 2 3 4 5]
	}
	
	//copy()复制切片 copy(destSlice, srcSlice []T)
	func main() {
		// copy()复制切片
		a := []int{1, 2, 3, 4, 5}
		c := make([]int, 5, 5)
		copy(c, a)     //使用copy()函数将切片a中的元素复制到切片c
		fmt.Println(a) //[1 2 3 4 5]
		fmt.Println(c) //[1 2 3 4 5]
		c[0] = 1000
		fmt.Println(a) //[1 2 3 4 5]
		fmt.Println(c) //[1000 2 3 4 5]
	}

	//删除切片
	//Go语言中并没有删除切片元素的专用方法，要从切片a中删除索引为index的元素，操作方法是a = append(a[:index], a[index+1:]...)
	func main() {
		// 从切片中删除元素
		a := []int{30, 31, 32, 33, 34, 35, 36, 37}
		// 要删除索引为2的元素
		a = append(a[:2], a[3:]...)
		fmt.Println(a) //[30 31 33 34 35 36 37]
	}


map
	//map 是一种元素对（key values pair）的无序集合,也称为关联数组或字典
	//声明变量b为map类型：var b map[string]int，需要用make函数进行初始化操作之后，才能对其进行键值对赋值
	//定义map： make(map[KeyType]ValueType, [cap])
	func main() {
		scoreMap := make(map[string]int, 8)  //创建空map
		scoreMap["张三"] = 90
		scoreMap["小明"] = 100
		fmt.Println(scoreMap)  				//map[小明:100 张三:90]
		fmt.Println(scoreMap["小明"])		//100
		fmt.Printf("type of a:%T\n", scoreMap)	//type of a:map[string]int

		// 如果key存在ok为true,v为对应的值；不存在ok为false,v为值类型的零值
		v, ok := scoreMap["张三"]
		if ok {
			fmt.Println(v)
		} else {
			fmt.Println("查无此人")
		}

		//遍历map
		for k, v := range scoreMap {
			fmt.Println(k, v)
		}
		//只遍历map的key
		for k := range scoreMap {
			fmt.Println(k)
		}

		//将小明:100从map中删除
		delete(scoreMap, "小明")	

		//map也支持在声明的时候填充元素
		userInfo := map[string]string{
			"username": "沙河小王子",
			"password": "123456",
		}
	}


函数
	//函数定义
	func 函数名(参数)(返回值){
	    函数体
	}

	//不带参数和返回值的函数
	func sayHello() {
		fmt.Println("Hello world")
	}

	//带参数的函数，指定参数类型，和返回值类型(函数的参数中如果相邻变量的类型相同，则可以省略类型)
	func intSum(x, y int) int {
		return x + y
	}

	//可变参数
	func myFunc(a, b, z ...int) {
	}

	func Greeting(prefix string, who ...string) {
	}
	Greeting("hello:", "Joe", "Anna", "Eileen")   //变量 who 的值为 []string{"Joe", "Anna", "Eileen"}

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

	//函数返回值，通过 return 关键字返回一组值，在函数块里面，return 之后的语句都不会执行
	//多返回值
	func calc(x, y int) (int, int) {
		sum := x + y
		sub := x - y
		return sum, sub
	}
	//函数定义时可以给返回值命名，并在函数体中直接使用这些变量，最后通过return关键字返回
	func calc(x, y int) (sum, sub int) {
		sum = x + y
		sub = x - y
		return
	}

	//type关键字来定义一个函数类型
	//定义了一个calculation类型，它是一种函数类型，这种函数接收两个int类型的参数并且返回一个int类型的返回值。
	type calculation func(int, int) int  
	//凡是满足这个条件的函数都是calculation类型的函数
	func add(x, y int) int {
		return x + y
	}
	func sub(x, y int) int {
		return x - y
	}
	//add和sub都能赋值给calculation类型的变量
	func main() {
		var c calculation               // 声明一个calculation类型的变量c
		c = add                         // 把add赋值给c
		fmt.Printf("type of c:%T\n", c) // type of c:main.calculation
		fmt.Println(c(1, 2))            // 像调用add一样调用c
	
		f := add                        // 将函数add赋值给变量f1
		fmt.Printf("type of f:%T\n", f) // type of f:func(int, int) int
		fmt.Println(f(10, 20))          // 像调用add一样调用f
	}

	//将函数作为参数，函数可以作为其它函数的参数进行传递，然后在其它函数内调用执行，一般称之为回调
	func add(x, y int) int {
		return x + y
	}
	func calc(x, y int, op func(int, int) int) int {
		return op(x, y)
	}
	func main() {
		ret2 := calc(10, 20, add)
		fmt.Println(ret2) //30
	}


	//匿名函数，即在需要使用函数时再定义函数，匿名函数没有函数名只有函数体
	func(参数)(返回值){
		函数体
	}
	//匿名函数可以被赋值于某个变量，即保存函数的地址到变量中
	fplus := func(x, y int) int { return x + y }
	调用匿名函数：fplus(3,4)
	//立即执行函数，第3行}后的(100)，表示对匿名函数进行调用，传递参数为 100,  输出：hello 100
	func(data int) {
		fmt.Println("hello", data)
	}(100)
	
	
	//闭包（闭包=函数+引用环境）
	func f() func(b int) int {     //函数f返回值为一个 函数(有参数b为int类型 返回值为int类型)
		return func(b int) int {
			return b
		}
	}
	func main() {
		a := f()
		print(a(5),"\n")  //5
		print(f()(3))	  //3,不通过变量引用，直接调用函数f()
	}

	// defer 语句会推迟函数（包括任何参数）的运行，直到包含 defer 语句的函数完成
	// defer 语句按逆序运行，先运行最后一个，最后运行第一个
	func main() {
		for i := 1; i <= 3; i++ {
			defer fmt.Println("deferred", -i)
			fmt.Println("regular", i)
		}
	} 
	//输出：
	regular 1
	regular 2
	regular 3
	deferred -3
	deferred -2
	deferred -1
	

	//内置函数
	close	主要用来关闭channel
	len	用来求长度，比如string、array、slice、map、channel
	new	用来分配内存，主要用来分配值类型，比如int、struct。返回的是指针
	make	用来分配内存，主要用来分配引用类型，比如chan、map、slice
	append	用来追加元素到数组、slice中
	panic和recover	用来做错误处理


指针
	//程序在内存中存储它的值，每个内存块（或字）有一个地址，通常用十六进制数表示，如：0x6b0820 或 0xf84001d7f0。
	//把内存地址赋值给变量B,B就是指针变量
	// & 取内存地址（不能得到一个文字或常量的地址）， * 根据地址取地址指向的值，取地址操作符&和取值操作符*是一对互补操作符
	// Go语言中的值类型（int、float、bool、string、array、struct）都有对应的指针类型，如：*int、*int64、*string等
	
	//取变量v的内存地址,内存地址可以存储在一个叫做指针的特殊数据类型中
	ptr := &v   //ptr为指针类型
	//v:代表被取地址的变量，类型为T
	//ptr:用于接收地址的变量，ptr的类型就为*T，称做T的指针类型。*代表指针
	a := 10  //值：10，内存地址：0xc000014090
	b := &a  //b是一个指针变量，值：0xc000014090  内存地址：0xc00000e028
	c := &b  //c是一个指针变量，值：0xc00000e028  内存地址：0xc00000e030
	d := *b	 //10，在指针类型前面加上 *号（前缀）来获取指针所指向的内容

	func main() {
		// 准备一个字符串类型
		var house = "Malibu Point 10880, 90265"
		// 指针变量ptr对字符串变量house取内存地址
		//ptr := &house      //0xc0420401b0
		var ptr *string = &house	//0xc0420401b0
		fmt.Printf("ptr type: %T\n", ptr)  //ptr的类型: *string （字符串类型的指针）

		// 对指针进行取值操作
		value := *ptr   //获取指针所指向的内容: "Malibu Point 10880, 90265"
		fmt.Printf("value type: %T\n", value) // 取值后的类型: string
		// 指针取值后就是指向变量的值
		fmt.Printf("value: %s\n", value)
	}


package
	//包（package）是多个Go源码的集合，是一种高级的代码复用方案，Go语言为我们提供了很多内置包，如fmt、os、io等。
	//一个包可以简单理解为一个存放.go文件的文件夹。 该文件夹下面的所有go文件都要在代码的第一行添加如下代码，声明该文件归属的包。
	package 包名
	/*
		一个文件夹下面直接包含的文件只能归属一个package，同样一个package的文件不能在多个文件夹下。
		包名可以不和文件夹的名字一样，包名不能包含 - 符号。
		包名为main的包为应用程序的入口包，这种包编译后会得到一个可执行文件，而编译不包含main包的源代码则不会得到可执行文件。
	*/

	//可见性,如果想在一个包中引用另外一个包里的标识符（如变量、常量、类型、函数等）时，该标识符必须是对外可见的（public）。在Go语言中只需要将标识符的首字母大写就可以让标识符对外可见了
	package pkg2
	import "fmt"

	// 包变量可见性
	var a = 100 // 首字母小写，外部包不可见，只能在当前包内使用

	// 首字母大写外部包可见，可在其他包中使用
	const Mode = 1

	type person struct { // 首字母小写，外部包不可见，只能在当前包内使用
		name string
	}

	// 首字母大写，外部包可见，可在其他包中使用
	func Add(x, y int) int {
		return x + y
	}

	func age() { // 首字母小写，外部包不可见，只能在当前包内使用
		var Age = 18 // 函数局部变量，外部包不可见，只能在当前函数内使用
		fmt.Println(Age)
	}


	//结构体中的字段名和接口中的方法名如果首字母都是大写，外部包可以访问这些字段和方法
	type Student struct {
		Name  string //可在包外访问的方法
		class string //仅限包内访问的字段
	}
	type Payer interface {
		init() //仅限包内访问的方法
		Pay()  //可在包外访问的方法
	}

	//包的导入
	import "包的路径"
	import 别名 "包的路径"
	//多行导入
	import (
		"fmt"
		m "github.com/Q1mi/studygo/pkg_test"
	 )
	/*
		import导入语句通常放在文件开头包声明语句的下面。
		导入的包名需要使用双引号包裹起来。
		包名是从$GOPATH/src/后开始计算的，使用/进行路径分隔。
		Go语言中禁止循环导入包
	*/

	//在Go语言程序执行时导入包语句会自动触发包内部init()函数的调用
	//init()函数没有参数也没有返回值。 init()函数在程序运行时自动被调用执行，不能在代码中主动调用它
	//Go语言包会从main包开始检查其导入的所有包，每个包中又可能导入了其他的包.在运行时，被最后导入的包会最先初始化并调用其init()函数
	包导入顺序：main -import-> A -import-> B -import-> C
	init执行顺序：c.init() -> B.init() -> A.init() -> main.init()


结构体（struct）
	//有时，你需要在一个结构体中表示字段的集合。 例如，要编写工资核算程序时，需要使用员工数据结构。 在 Go 中，可使用结构将可能构成记录的不同字段组合在一起。
	//Go 中的结构体也是一种数据结构，它可包含零个或多个任意类型的字段，并将它们表示为单个实体。类似面向对象class。

	//type关键字来定义自定义类型:
	type MyInt int   //通过type关键字的定义，MyInt就是一种新的类型，它具有int的特性

	//定义结构体：
	type 类型名 struct {
		字段名 字段类型
		字段名 字段类型
		…
	}
	/*
		类型名：标识自定义结构体的名称，在同一个包内不能重复。
		字段名：表示结构体字段名。结构体中的字段名必须唯一。
		字段类型：结构体的字段可以是任何类型，甚至是结构体本身，也可以是函数或者接口
	*/

	type person struct {
		name string
		city string
		age  int8
	}

	//初始化结构体，没有初始化的结构体，其成员变量都是对应其类型的零值
	func main() {
		var p1 person	//初始化结构体
		p1.name = "xikai"
		p1.city = "shenzhen"
		p1.age = 18
	}

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

	//匿名结构体
	func main() {
		var user struct{Name string; Age int}
		user.Name = "小王子"
		user.Age = 18
		fmt.Printf("%#v\n", user)
	}

	//new关键字对结构体进行实例化,创建指针类型结构体
	var p2 = new(person)
	p2.name = "小王子"
	p2.age = 28
	p2.city = "上海"
	fmt.Printf("%T\n", p2)     //*main.person
	fmt.Printf("p2=%#v\n", p2) //p2=&main.person{name:"", city:"", age:0}

	//使用键值对对结构体进行初始化时，键对应结构体的字段，值对应该字段的初始值
	p5 := person{
		name: "小王子",
		city: "北京",
		age:  18,
	}
	fmt.Printf("p5=%#v\n", p5) //p5=main.person{name:"小王子", city:"北京", age:18}

	// & 运算符生成指向结构的指针
	p6 := &person{
		name: "小王子",
		city: "北京",
		age:  18,
	}
	fmt.Printf("p6=%#v\n", p6) //p6=&main.person{name:"小王子", city:"北京", age:18}

	//初始化结构体的时候可以简写，也就是初始化的时候不写键，直接写值
	p8 := &person{
		"沙河娜扎",
		"北京",
		28,
	}
	fmt.Printf("p8=%#v\n", p8) //p8=&main.person{name:"沙河娜扎", city:"北京", age:28}

	//结构体匿名字段,结构体允许其成员字段在声明时没有字段名而只有类型，这种没有名字的字段就称为匿名字段。
	//这里匿名字段的说法并不代表没有字段名，而是默认会采用类型名作为字段名，结构体要求字段名称必须唯一，因此一个结构体中同种类型的匿名字段只能有一个
	type Person struct {
		string
		int
	}
	func main() {
		p1 := Person{
			"小王子",
			18,
		}
		fmt.Printf("%#v\n", p1)        //main.Person{string:"北京", int:18}
		fmt.Println(p1.string, p1.int) //北京 18
	}

	//嵌套结构体 “继承”
	//Address 地址结构体
	type Address struct {
		Province string
		City     string
	}
	//User 用户结构体
	type User struct {
		Name    string
		Gender  string
		Address Address
	}
	func main() {
		user1 := User{
			Name:   "小王子",
			Gender: "男",
			Address: Address{
				Province: "山东",
				City:     "威海",
			},
		}
		fmt.Printf("user1=%#v\n", user1)//user1=main.User{Name:"小王子", Gender:"男", Address:main.Address{Province:"山东", City:"威海"}}
	}

	//构造函数
	type File struct {
		fd	int
		name string
	}
	func NewFile(f int, na string) *File {
		if f < 0 {
			return nil
		}
		return &File{f, na}
	}
	func main() {
		f := NewFile(10,"./test.txt")
		fmt.Println(f)
	}

	//方法（在 Go 语言中，结构体就像是类的一种简化形式）
	//Go方法是作用在接收者（receiver）上的一个函数，接收者是某种类型（不能是接口类型）的变量。因此方法是一种特殊类型的函数。

	//定义方法（在方法名之前，func 关键字之后的括号中指定 receiver）
	//recv 就像是面向对象语言中的 this 或 self，但是 Go 中并没有这两个关键字。随个人喜好，你可以使用 this 或 self 作为 receiver 的名字。
	func (recv receiver_type) methodName(parameter_list) (return_value_list) { ... }

	//结构体类型方法 method .go
	package main
	import "fmt"

	type TwoInts struct {
	    a int
	    b int
	}

	func main() {
	    two1 := new(TwoInts)
	    two1.a = 12
	    two1.b = 10

	    fmt.Printf("The sum is: %d\n", two1.AddThem())						//The sum is: 22
	    fmt.Printf("Add them to the param: %d\n", two1.AddToParam(20))		//Add them to the param: 42

	    two2 := TwoInts{3, 4}
	    fmt.Printf("The sum is: %d\n", two2.AddThem())						//The sum is: 7
	}

	func (tn *TwoInts) AddThem() int {
	    return tn.a + tn.b
	}

	func (tn *TwoInts) AddToParam(param int) int {
	    return tn.a + tn.b + param
	}

	//giveRaise.go
	package main
	import "fmt"

	type employee struct {
		name string
		salary float32
	}

	func (em *employee) giveRaise(raise float32) *employee {
		em.salary = float32(em.salary) + float32(em.salary) * raise
		return &employee{em.name, em.salary}
	}

	func main() {
		f := (&employee{"张三",10000.00}).giveRaise(0.2)
		fmt.Println(f)	//&{张三 12000}
	}

	//非结构体类型上方法 method2.go
	package main
	import "fmt"

	type IntVector []int

	func (v IntVector) Sum() (s int) {   //v接收切片IntVector{1, 2, 3}
		for _, x := range v {
			s += x
		}
		return
	}

	func main() {
		fmt.Println(IntVector{1, 2, 3}.Sum()) // 输出是6
	}


interface
	//在Go语言中接口（interface）是一种类型，一种抽象的类型。接口（interface）定义了一个对象的行为规范，只定义规范不实现，由具体的对象来实现规范的细节。
	type 接口类型名 interface{
		方法名1( 参数列表1 ) 返回值列表1
		方法名2( 参数列表2 ) 返回值列表2
		…
	}
	/*
		接口名：使用type将接口定义为自定义的类型名。Go语言的接口在命名时，一般会在单词后面添加er，如有写操作的接口叫Writer，有字符串功能的接口叫Stringer等。接口名最好要能突出该接口的类型含义。
		方法名：当方法名首字母是大写且这个接口类型名首字母也是大写时，这个方法可以被接口所在的包（package）之外的代码访问。
		参数列表、返回值列表：参数列表和返回值列表中的参数变量名可以省略。
	*/
	// 为什么要使用接口
	type dog struct {}
	func (d dog) say() {
		fmt.Println("汪汪汪")
	}
	type cat struct {}
	func (c cat) say() {
		fmt.Println("喵喵喵")
	}
	func main() {
		c := Cat{}
		fmt.Println("猫:", c.Say())
		d := Dog{}
		fmt.Println("狗:", d.Say())
	}
	/*
		上面的代码中定义了猫和狗,你会发现main函数中明显有重复的代码,如果我们后续再加上猪、青蛙等动物的话，我们的代码还会一直重复下去。那我们能不能把它们当成“能叫的动物”来处理呢？
		比如一个网上商城可能使用支付宝、微信、银联等方式去在线支付，我们能不能把它们当成“支付方式”来处理呢？
		比如三角形，四边形，圆形都能计算周长和面积，我们能不能把它们当成“图形”来处理呢？
		比如销售、行政、程序员都能计算月薪，我们能不能把他们当成“员工”来处理呢？
		Go语言中为了解决类似上面的问题，就设计了接口这个概念。接口区别于我们之前所有的具体类型，接口是一种抽象的类型。当你看到一个接口类型的值时，你不知道它是什么，唯一知道的是通过它的方法能做什么。
	*/

	//接口就是一个需要实现的方法列表。一个对象只要实现了接口中的全部方法，那么就实现了这个接口
	//只要实现了say()这个方法的类型都可以称为sayer类型
	type sayer interface {
		say()
	}

	type dog struct {}
	// dog实现sayer接口
	func (d dog) say() {
		fmt.Println("汪汪汪")
	}

	type cat struct {}
	// cat实现sayer接口
	func (c cat) say() {
		fmt.Println("喵喵喵")
	}

	type persion struct {
		name string
	}
	// persion实现say接口
	func (p person) say() {
		fmt.Println("啊啊啊")
	}

	func da(arg sayer)  {
		arg.say()
	}

	func main()  {
		c1 := cat{}
		da(c1)		//喵喵喵
		d1 := dog{}
		da(d1)		//汪汪汪
		p1 := person{}
		da(p1)		//啊啊啊
	}


	//使用值接收者实现接口和使用指针接收者实现接口的区别
		type mover interface {
			move()
		}
		type person struct {
			name string
			age int
		}

		//使用值接收者实现接口
		func (p person) move() {
			fmt.Printf("%s在跑\n", p.name)
		}	
		func main()  { //使用值接收者实现接口：类型的值和类型的指针都能保存到接口变量中
			var m mover
			p1 := person{name: "小王了", age: 18}	//p1是person类型的值
			p2 := &person{name: "盖伦", age: 18}		//p2是person类型的指针
			m = p1
			m.move()	//小王了在跑
			m = p2
			m.move()	//盖伦在跑
		}

		//使用值接收者实现接口
		func (p *person) move() {
			fmt.Printf("%s在跑\n", p.name)
		}
		func main()  {	//只有类型指针能保存到接口变量中
			var m mover
			//p1 := person{name: "小王了", age: 18}	//p1是person类型的值
			p2 := &person{name: "盖伦", age: 18}		//p2是person类型的指针
			//m = p1		//./test.go:21:4: person does not implement mover (move method has pointer receiver)
			//m.move()
			m = p2
			m.move()		//盖伦在跑
		
		}

	//一个类型实现多个接口
		type mover interface {
			move()
		}
		type sayer interface {
			say()
		}
		//一个person类型
		type person struct { 
			name string
			age int
		}
		//实现mover接口
		func (p *person) move() {
			fmt.Printf("%s在跑\n", p.name)
		}
		//实现sayer接口
		func (p *person) say() {
			fmt.Printf("%s在叫\n", p.name)
		}
		func main()  {
			var m mover
			var s sayer
			p2 := &person{name: "盖伦", age: 18}
			m = p2
			m.move()
			s = p2
			s.say()
		}

	//接口嵌套接口
	type ReadWrite interface {
		Read(b Buffer) bool
		Write(b Buffer) bool
	}
	type Lock interface {
		Lock()
		Unlock()
	}
	type File interface {
		ReadWrite
		Lock
		Close()
	}

	//空接口
	//接口中没有定义任何需要实现的方法时，该接口就是一个空接口
	//任意类型都实现了空接口 --> 空接口变量可以存储任意值
	func main()  {
		var x interface{}
		x = "hello"
		fmt.Println(x)
		x = 100
		fmt.Println(x)
		x = false
		fmt.Println(x)
	}

	//空接口的应用
	//空接口作为函数参数
	func show(a interface{}) {
		fmt.Printf("type:%T value:%v\n", a, a)
	}
	// 空接口作为map值
	var studentInfo = make(map[string]interface{})
	studentInfo["name"] = "沙河娜扎"
	studentInfo["age"] = 18
	studentInfo["married"] = false
	fmt.Println(studentInfo)

	//接口类型断言（猜测）
	func main()  {
		var x interface{}
		x = "hello"
		fmt.Println(x.(string))   //猜对了打印接口值： hello
		x = 100
		fmt.Println(x.(bool))  	  //panic: interface conversion: interface {} is int, not bool
	}