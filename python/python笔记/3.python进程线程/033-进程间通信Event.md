### 信号(状态)通信
* Event ：一般用来控制进程间执行顺序的
  * 父进程开启了一个子进程
    * 子进程在工作的时候，必须是有某些条件达成
  * from multiprocessing import Event 
    * e = Event()
    * e.wait() 在进程内部设置为阻塞
    * e.set() 把e状态设置为开启 True
    * e.clear() 把e状态设置为阻塞 False

### Event-进程间通信
```python
from multiprocessing import Event,Process
import time
from datetime import datetime
from psutil import cpu_count
 
'''
cpu_num = cpu_count()
p = []
for var in range(cpu_num):
    p.append(Process(...))
'''
 
def work(e,):
    # 子进程
    while True:
        #print('我是子进程,我先休息!')
        e.wait() #阻塞等待信号
        print('[S] 这是我的定时任务！')
        e.clear() #执行一下 就不再执行了
 
#信号：
    #某一些用户链接的时候，Nginx就会做出相应
    #Epoll: 信号|事件
 
#21点51分
def main():
    e = Event()
    a = int()
    p = Process(target=work,name='子进程',args=(e,))
    p.start()
    while True:
        if datetime.now().second == 55:
            print('[F] 子进程取消阻塞状态')
            e.set() #父进程设置的e，那么子进程会不会回复工作
#Django
    #Html 前端部分 2-3天
    #爬虫
    #自动化运维
if __name__ == '__main__':
    main()
```


---
### 总结
* 非阻塞：Queue支持 
  * 缺点：取数据娶不到的时候，直接抛出异常
  * 好处：是不影响接下来的事情
  * 分清楚，接下里的事情有没有用到阻塞时要获取到的数据
* 阻塞：
  * Queue和Pipe均支持
    * 访问数据的时候，安全
    * 会影响到下面继续工作的和这个数据无关紧要的内容
* Queue：
  * 好用  
    * q.get
    * q.put
  * 可以多进程对多进程通信，方便
  * 一定要记得维护阻塞非阻塞。
* Pipe：
  * 多对多进程通信比较麻烦维护
  * 也支持一对多进程和一对一进程通信，父子进程通信。