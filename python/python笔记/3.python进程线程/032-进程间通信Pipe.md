### Pipe：管道，默认为全双工
 
* **全双工**：可以同时（瞬时）进行信号的双向传输（A→B且B→A）
* 单工：只允许甲方向乙方传送信息，而乙方不能向甲方传送(A→B) （比喻汽车的单行道）
* 半双工：指一个时间段内只有一个动作发生(A→B或B→A)（对讲机）

* 管道传输的数据一定是一个pickle模块处理过后的pickle数据，是一个二进制的。
* from multiprocessing import Process,Pipe
  * Pipe(duplex=True) 全双工，默认为True
  * left_pipe,right_pipe = Pipe(duplex=True)
  * parent_pipe,child_pipe = Pipe(duplex=True)
  * pickle_obj = pipe.recv() 
    * 从端口中读数据
  * pipe.send(pickle_obj) 
    * 从端口中写数据
  * pipe.close()
    * 关闭管道，在不适用的时候一定要记得关闭两端。
* 只支持两端对话，所以多进程超过2以上，那么可能需要换一种模型，或者创建多管道。

### 阻塞-Pipe全双工管道
```python
from multiprocessing import Process,Pipe
import pickle
 
def func_left(pipe):
    #左边先写给右边、
    msg = '我是left'
    pipe.send(pickle.dumps(msg)) #把原始字符串数据变成pickle格式
 
    ret = pickle.loads(pipe.recv())#解析pickle数据
    print('右边进程从端口里发来:',ret)
 
def func_right(pipe):
    #右边的先读取左边的
    ret = pickle.loads(pipe.recv())#解析pickle数据
    print('左边进程从端口里发来:',ret)
 
    msg = '我是right'
    pipe.send(pickle.dumps(msg))
 
def main():
    left,right = Pipe() # 全双工管道
        #parent,child 一对端口
    p1 = Process(target=func_left,name='左',args=(left,))
    p2 = Process(target=func_right,name='右',args=(right,))
 
    p1.start()
    p2.start()
 
    p1.join()
    p2.join()
 
if __name__ == '__main__':
    main()
```

### pipe-生产者消费者模型
```python
#生产者：生成数据
#消费者：拿取数据
    #管道:
        #A（生产者）：写入 send
        #B（消费者）：拿取 recv
from multiprocessing import Process,current_process,Pipe
import pickle
 
def l_func(pipe):
    #生产者
    for var in range(10):
        print('%s: 生产数据 | %s' % (current_process().name,var))
        pipe.send(pickle.dumps(var))
 
def r_func(pipe):
    #消费者
    for var in range(10):
        ret = pickle.loads(pipe.recv())
        print('%s: 接收数据 | %s' % (current_process().name,ret))
         
def main():
    #Atom浏览器内核 会比较难用
    l,r = Pipe() #创建管道
    l_p = Process(target=l_func,name='生产者',kwargs={'pipe':l})
    r_p = Process(target=r_func,name='消费者',kwargs={'pipe':r})
 
    l_p.start()
    r_p.start()
    #---------------
        #孤儿进程有危害  init
    l_p.join()
    r_p.join()
if __name__ == '__main__':
    main()
```

### pipe-生产者消费者模型
```python
#生产者：生成数据
#消费者：拿取数据
    #管道:
        #A（生产者）：写入 send
        #B（消费者）：拿取 recv
from multiprocessing import Process,current_process,Pipe
import pickle
 
#阻塞等待管道内信息
# 最优解
 
def l_func(pipe):
    #生产者
    for var in range(150000):
        print('%s: 生产数据 | %s' % (current_process().name,var))
        pipe.send(pickle.dumps(var))
 
def r_func(pipe):
    for var in range(30000): #每个消费者消费3次
        ret = pickle.loads(pipe.recv())
        print('%s: 接收数据 | %s' % (current_process().name,ret))
 
def main():
    #Atom浏览器内核 会比较难用
    l,r = Pipe() #创建管道
    l_p = Process(target=l_func,name='生产者',kwargs={'pipe':l})
    r_p = [] #消费者进程队列
    for var in range(5): #有5个消费者 
        r_p.append(Process(target=r_func,name='消费者%d' % var,kwargs={'pipe':r}))
 
    l_p.start() #先开启生产者
    for p in r_p:
        p.start()
    #---------------
        #孤儿进程有危害  init
    l_p.join()
    for p in r_p:
        p.join()
if __name__ == '__main__':
    main()
```