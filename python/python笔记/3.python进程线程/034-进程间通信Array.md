### Array(共享内存)
 
* 底层C语言实现的，Linux内核的东西。效率非常高，但是支持性差
 
* from multiprocessing import Array
 
  ```powershell
  a = Array(typecode_or_type,size_or_initializer,lock=True)
   
  typecode_or_type：数据类型
    unsigned  signed 
  chr:    b       B     8位
  short:  h       H
  int:    i       I
  long:   l       L
  float:      f
  double:     d
  size_or_initializer：数据长度
  lock：当有一个进程在访问这个数据资源的时候，其他进程访问不了。
    当lock为True时，我们可以在访问的时候，通过下面两个函数来保护数据的访问顺序：
    a.acquire() 持锁
    a.release() 释放锁
  Array共享数组，更安全的通信方式
  ```
 
* 创建出来的a是一个抽象的共享数组，那么可以通过类似列表切片的方式来实际展开其中数据。

```python
from multiprocessing import Process,Array,current_process
 
def work_A(a):
    a.acquire()
    var = a[0]
    for var in range(10000):
        print('当前进程:%s | 获取到的数组:%s' % (current_process().name,a[:]))
        a[0] += 1
    a.release()
 
    #没加锁的代码
    # for var in range(100000): #10万
    #     print('当前进程:%s *****' % (current_process().name))
 
 
def work_B(a):
    #a.acquire() 
    for var in range(10000): #1万
        print('当前进程:%s | 获取到的数组:%s' % (current_process().name,a[:]))
        a[0] += 2
    #a.release()
 
    #没加锁 
    # for var in range(10000): #1万
    #     print('当前进程:%s -----' % (current_process().name))
 
 
def work_C(a):
    #a.acquire()
    var = a[0]
    for var in range(10000):
        print('当前进程:%s | 获取到的数组:%s' % (current_process().name,a[:]))
    a[0] = 3
    #a.release()
 
def main():
    a = Array('i',3,lock=True) #3个长度的只能保存整型的数组
 
    p1 = Process(target=work_A,args=(a,),name='1 号进程')
    p2 = Process(target=work_B,args=(a,),name='2 号进程')
    p3 = Process(target=work_C,args=(a,),name='3 号进程')
 
    p1.start()
    p2.start()
    p3.start()
 
    p1.join()
    p2.join()
    p3.join()
    print('-------------------')
    print('父进程:',a[:])
 
if __name__ == '__main__':
    main()

```

### 练习
```python
#多进程
#进程间通信
from multiprocessing import Process,Array,current_process,Event
import random
import time
#Human:
    #吃饭
    #喝水
    #玩游戏
    #上厕所
 
#上厕所的时候，不能吃饭
#上厕所的时候，不能喝水
#上厕所的时候，不能玩游戏
 
def eat(Human,e,index): #吃饭1   默认醒来之后数据是0 吃了饭之后 数据要变成1
    e.set()
    Human[0] = 1
    for var in range(10):
        e.wait()
        time.sleep(0.5)
        print(current_process().name,index)
    print('吃完了')
 
def drink(Human,e,index):#喝水2
    e.set()
    Human[0] = 2
    for var in range(15):
        e.wait()
        time.sleep(0.5)
        print(current_process().name,index)
    print('喝完了')
 
def play(Human,e,index): #玩耍3
    e.set()
    Human[0] = 3
    for var in range(6):
        e.wait()
        time.sleep(0.5)
        print(current_process().name,index)
    print('耍完了')
 
 
def wc(Human,e,index):#厕所4
 
    Human.acquire() #你只能干这件事
    Human[0] = 4
    for var in range(30):
        e.clear() #让其他进程等待
        time.sleep(0.5)
        print(current_process().name,index)
    Human.release()
    print('舒服...',index)
    e.set() #上完厕所别人可以执行！
 
#这个锁有意义吗?
def main():
    Human = Array('i',1,lock=True)
    e = Event()
    today = ['吃饭','喝水','玩耍','厕所']
    func_dict = {
        '吃饭':eat,
        '喝水':drink,
        '玩耍':play,
        '厕所':wc
    }
    work_list = []
    index = 0
    while True:
        if index == 4:
            break
        last_things = random.choice(today)
        p = Process(target=func_dict[last_things],name=last_things,args=(Human,e,index)) #
        p.start()
        work_list.append(p)
        index += 1
 
 
    for p in work_list:
        p.join()
 
if __name__ == '__main__':
    main()

```