package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()

	//时间类型
	year := now.Year()     //年
	month := now.Month()   //月
	day := now.Day()       //日
	hour := now.Hour()     //小时
	minute := now.Minute() //分钟
	second := now.Second() //秒
	week := now.Weekday() //星期
	timezone := now.Location() //时区

	fmt.Println(now)	//2021-04-21 16:17:34.201752 +0800 CST m=+0.000115160
	fmt.Printf("%d-%02d-%02d %02d:%02d:%02d %s %s\n", year, month, day, hour, minute, second, week, timezone)

	//时间戳
	timestamp := now.Unix()	 //时间戳
	nanos := now.UnixNano()		 //纳秒时间戳

	fmt.Printf("current timestamp:%v\n", timestamp)
	fmt.Printf("current nanos timestamp:%v\n", nanos)

	//时间操作
	later := now.Add(time.Hour) // time.Add当前时间加1小时后的时间
	diff := later.Sub(now)	//time.Sub求两个时间的差值
	eqtime := now.Equal(later)	//time.Equal判断两个时间是否相同
	beforetime := now.Before(later)	//time.Beforce判读是否在某时间之前
	aftertime := now.After(later)  //time.After判断是否在某时间之后

	fmt.Println(later)	//2021-04-21 16:18:34.201752 +0800 CST m=+0.000115160
	fmt.Printf("%s %t %t %t\n", diff, eqtime, beforetime, aftertime)	//1h0m0s false true false

	//时间格式化(格式化的模板为Go的出生时间2006年1月2号15点04分 Mon Jan)
	fmt.Println(now.Format("2006-01-02 15:04:05.000 Mon Jan"))	//2021-05-14 18:50:49.740 Fri May
	fmt.Println(now.Format("2006-01-02 03:04:05.000 PM Mon Jan")) //2021-05-14 06:50:49.740 PM Fri May (PM表示12小时制)
	fmt.Println(now.Format("2006/01/02 15:04"))	//2021/05/14 18:50
	fmt.Println(now.Format("15:04 2006/01/02"))	//18:50 2021/05/14
	fmt.Println(now.Format("2006/01/02"))	//2021/05/14

	//定时器
	//tickDemo() //每秒打印一次当前时间

}

//time.Tick(时间间隔)来设置定时器
func tickDemo() {
	ticker := time.Tick(time.Second) //定义一个1秒间隔的定时器
	for i := range ticker {
		fmt.Println(i)//每秒都会执行的任务
	}
}