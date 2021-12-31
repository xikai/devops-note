# [rate / irate](https://segmentfault.com/a/1190000040783147)
* rate 计算指定时间范围内数据缓慢变化率
```
取时间范围内的firstValue和lastValue；
变化率 = (lastValue - firstValue) / Range；
```

* irate 计算指定时间范围内数据快速变化率
```
取时间范围内的lastValue和lastBeforeValue = (lastValue - 1)；
变化率 = (lastValue - lastBeforeValue) / Range；
```