# 多进程通信
 
### Queue：共享消息队列
* Rabbit Message Queue 和我们的Queue类似。
* 什么数据都可以装！甚至是文件对象，数据库句柄，对象，都可以！
  * 但是无法直接看到这个共享队列里的数据
  * <multiprocessing.queues.Queue object at 0x7f1388bdb4a8>
* 特殊的数据，可以在多进程之间共享这个队列
* from **multiprocessing** import Queue
* q = Queue()
  * 阻塞：会等待操作成功执行之后才会有返回。你才能继续接下来的事情。
  * q.**get**(block=True) 阻塞 | q.get_nowait 非阻塞
    * 向队列中取一个值出来
  * q.**put**(block=True) 阻塞 | q.put_nowait 非阻塞
    * 向队列中放一个值进去
    * 成功放入返回None，反之则抛出异常
  * q.empty()
    * 判断共享队列是否为空
  * q.full()
    * 判断队列是否是满的
  * q.qsize()
    * 返回当前共享队列的数据个数
  * q.close()
    * 关闭共享队列
 
* 进程的创建并不代表进程的实际执行顺序，所以叫并发。
  * 如果需要维护进程间执行顺序，需要同步

### 阻塞-多进程访问Queue队列
```python
from multiprocessing import Queue,Process,current_process
#取的时候会不会是一个顺序的
def func_get(q):
    p = current_process()
    for var in range(50000):
        ret = q.get()
        print('%s取到了:%s',(p.name,ret))
         
def main():
    q = Queue()
    for var in range(150000):
        q.put(var)
    #q = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
    p1 = Process(target=func_get,name='p1',args=(q,)) #0,1,2,3,4
    p2 = Process(target=func_get,name='p2',args=(q,)) #5,6,7,8,9
    p3 = Process(target=func_get,name='p3',args=(q,))
    p1.start()
    p2.start()
    p3.start()
    p1.join()
    p2.join()
    p3.join()
# 单核： 涉及不到CPU切换
if __name__ == '__main__':
    main()
```

### 阻塞-(Queue)消费者生产者模型
```python
from multiprocessing import Queue,Process,current_process
import time
#一个生产，一个取
#列表的测试
def func_get(q):
    p = current_process()
    print('我是子进程:',p.name)
    for var in range(10):
        #time.sleep(1)
        ret = q.get()
        print('我取到了:',ret)
        print('***************')
 
#多进程下，进程的顺序是无法控制的
def func_put(q):
    p = current_process()
    print('我是子进程:',p.name)
    for var in range(10):
        time.sleep(0)
        q.put(var)
        print('我放进去了:',var)
        print('---------------')
 
def main():
    q = Queue()
    p_get = Process(target=func_get,name='拿取进程',args=(q,))
    p_put = Process(target=func_put,name='存放进程',args=(q,))
    #开启子进程
    p_get.start() #先取
    p_put.start() #后放
    #回收子进程
    p_get.join()
    p_put.join()
 
    q.put(1)
    q.put(1)
    q.put(1)
    print(q)
    #<multiprocessing.queues.Queue object at 0x7f1388bdb4a8>
        #这个共享队列无法直接看到里面的内容
    q.close()
if __name__ == '__main__':
    main()
```

### 非阻塞-(Queue)消费者生产者模型
```python
from multiprocessing import Queue,Process,current_process
import time
 
#列表的测试
def func_get(q):
    p = current_process()
    print('我是子进程:',p.name)
    for var in range(10):
        #time.sleep(1)
        ret = q.get(block=False) #非阻塞 取不到数据 直接抛出异常queue.Empty异常
        #q.get(block=False) q.get_nowait()
        print('我取到了:',ret)
        print('***************')
 
#多进程下，进程的顺序是无法控制的
def func_put(q):
    p = current_process()
    print('我是子进程:',p.name)
    for var in range(10):
        #time.sleep(1)
        q.put_nowait(var)
        print('我放进去了:',var)
        print('---------------')
#在非阻塞模型下，有先后顺序！
    #1:func_get
    #2:func_put
def main():
    q = Queue()
    p_get = Process(target=func_get,name='拿取进程',args=(q,))
    p_put = Process(target=func_put,name='存放进程',args=(q,))
    #开启子进程
    #CPU执行的顺序 不是你开启进程的顺序
    p_put.start()
    #time.sleep(1)
    p_get.start() #反而在取的时候被CPU首先执行
 
    #回收子进程
    p_get.join()
    p_put.join()
 
    q.put(1)
    q.put(1)
    q.put(1)
    print(q)
    #<multiprocessing.queues.Queue object at 0x7f1388bdb4a8>
        #这个共享队列无法直接看到里面的内容
    q.close()
if __name__ == '__main__':
    main()
```


 
