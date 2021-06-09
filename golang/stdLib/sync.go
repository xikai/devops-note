//sync.WaitGroup来实现并发任务的同步
//WaitGroup用于等待一组线程的结束。父线程调用Add方法来设定应等待的线程的数量。每个被等待的线程在结束时应调用Done方法。同时，主线程里可以调用Wait方法阻塞至所有线程结束。
var wg sync.WaitGroup
wg.Add(delta int)	//Add方法向内部计数加上delta,如果内部计数器变为0，Wait方法阻塞等待的所有线程都会释放，如果计数器小于0，方法panic。
wg.Done()			//Done方法减少WaitGroup内部计数器的值
wg.Wait()			//Wait方法阻塞直到WaitGroup计数器减为0

func main()  {
	wg := sync.WaitGroup{}	//sync.WaitGroup用于等待一组线程的结束
	fmt.Println("main")

	wg.Add(1)	//计数器+1
	go func() {
		for i:=0;i<10;i++ {
			fmt.Println(i)

		}
		wg.Done()	//计数器-1
	}()

	wg.Wait()	//阻塞直到计数器变为0
}


//sync.Once提供了一个针对只执行一次场景的解决方案
var loadIconsOnce sync.Once
func loadIcons() {
	icons = map[string]image.Image{
		"left":  loadIcon("left.png"),
		"up":    loadIcon("up.png"),
		"right": loadIcon("right.png"),
		"down":  loadIcon("down.png"),
	}
}
// Icon 是并发安全的
func Icon(name string) image.Image {
	loadIconsOnce.Do(loadIcons)
	return icons[name]
}
//sync.Map Go语言中内置的map不是并发安全的,当并发多了之后执行上面的代码就会报fatal error: concurrent map writes错误。
var m = make(map[string]int)
func get(key string) int {
	return m[key]
}
func set(key string, value int) {
	m[key] = value
}
func main() {
	wg := sync.WaitGroup{}
	for i := 0; i < 20; i++ {
		wg.Add(1)
		go func(n int) {
			key := strconv.Itoa(n)
			set(key, n)
			fmt.Printf("k=:%v,v:=%v\n", key, get(key))
			wg.Done()
		}(i)
	}
	wg.Wait()
}


//为map加锁来保证并发的安全性了
//sync包中提供了一个开箱即用的并发安全版map–sync.Map。开箱即用表示不用像内置的map一样使用make函数初始化就能直接使用。同时sync.Map内置了诸如Store、Load、LoadOrStore、Delete、Range等操作方法。
var m = sync.Map{}
func main() {
	wg := sync.WaitGroup{}
	for i := 0; i < 20; i++ {
		wg.Add(1)
		go func(n int) {
			key := strconv.Itoa(n)
			m.Store(key, n)
			value, _ := m.Load(key)
			fmt.Printf("k=:%v,v:=%v\n", key, value)
			wg.Done()
		}(i)
	}
	wg.Wait()
}