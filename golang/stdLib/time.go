package main

import (
	"fmt"
	"time"
)

func main() {
	p := fmt.Println

	now := time.Now()
	p(now)				//2021-04-21 16:17:34.201752 +0800 CST m=+0.000115160

	secs ：= now.Unix()			//时间戳，秒
	nanos := now.UnixNano()		//时间戳，纳秒
	millis := nanos / 100000	//时间戳，毫秒
	p(secs)		//1619001201
	p(nanos)	//1619001235698711000
	p(millis)  //16190014169536

	then := time.Date(2009, 11, 17, 20, 34, 58, 651387237, time.UTC)
	p(then)					//2009-11-17 20:34:58.651387237 +0000 UTC
	p(then.Year())			//2009
	p(then.Month())			//November
	p(then.Day())			//17
	p(then.Hour())			//20
	p(then.Minute())		//34
	p(then.Second())		//58
	p(then.Nanosecond())	//651387237 纳秒
	p(then.Location())		//UTC

	p(then.Weekday())		//Tuesday
	p(then.Before(now))		//true, 比较then是否在now时间之前
	p(then.After(now))		//false,比较then是否在now时间之后
	p(then.Equal(now))		//false,比较then是否和now时间相同

	diff := now.Sub(then)	//返回两个时间点的间隔时间
	p(diff)					//100139h51m44.528945763s
	p(diff.Hours())			//返回两个时间点的小时间隔，100140.6388557066
	p(diff.Minutes())		//返回两个时间点的分钟间隔，6.008438331342396e+06
	p(diff.Seconds())		//返回两个时间点的秒间隔，3.6050629988054377e+08
	p(diff.Nanoseconds())	//返回两个时间点的微秒间隔，360506299880543763

	p(then.Add(diff))		//将时间后移一个时间间隔
	p(then.Add(-diff))		//将时间前移一个时间间隔
}