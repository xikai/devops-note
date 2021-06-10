//读文件
func main() {
	file, err := os.Open("hello.go")
	defer file.Close()
	if err != nil {
		fmt.Println("open file failed!, err:", err)
	}
	bytes := make([]byte, 100)            //初始化要读取的字节数
	readbytes, err := file.Read(bytes)    //从文件中读取多少字节，返回读取的字节数和错误
	fmt.Println(string(bytes), readbytes) //string(bytes)读取到内容转化为字符串，readbytes读取成功的字符数量100
}

//写文件
func main() {
	mydata := []byte("hello world \n hello golang") //定义一个字符切片
	file, err1 := os.Create("1.txt")                //创建文件
	defer file.Close()                              //延迟关闭文件
	nums, err2 := file.Write(mydata)                //写入字符切片
	fmt.Println(nums, err1, err2)
}