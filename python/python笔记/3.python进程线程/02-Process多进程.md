# Python创建多进程
* multiprocessing，python2.6之后版本才有的，属于内置模块，不需要额外安装
* 这个模块支持跨平台，支持Windows，类Unix
  * os.fork创建多进程：os.fork只支持linux
  ```python
  import os
  import time
  # 这个代码运行之后 是一个进程在执行吗？
  return_fork = os.fork()
      #os.getpid() 返回当前程序的进程ID值
  if return_fork == 0: #return_fork 函数返回值        #1
      #子进程：os.fork函数返回0
      print("这是子进程:",os.getpid())
      time.sleep(5)
  else:                                              #2
      #父进程: 返回的是子进程的ID值
      print('这是父进程:',os.getpid())
      time.sleep(5)
      #只会在父进程里重新创建新的子进程？
      return_fork = os.fork()
      print('---------------------') #分割线会打印几次？
      if return_fork == 0: #return_fork 函数返回值    #3
          #子进程：os.fork函数返回0
          print("新的子进程:",os.getpid())
          time.sleep(5)
      else:                                          #2
          #父进程: 返回的是子进程的ID值
          print('这是父进程:',os.getpid())
          time.sleep(5)
   
  #写一个完美的进程池：
          #libevent apache内置的压力测试工具 apache
  #这个代码 几个子进程？
   
   
  # pid     ppid
  #root     25252 25030  0 21:58 pts/0    00:00:00 python3 os_fork?建多?程.py
  #root     25253 25252  0 21:58 pts/0    00:00:00 python3 os_fork?建多?程.py
  # 子进程的父亲是 25252
  #你觉的我能不能通过fork一次性开启超过1个以上的子进程
  #如果有多个子进程，那么父进程是哪个子进程的PID
   
  #父进程和子进程一样，所有里面的判断在父进程执行一次，子进程也执行了一次
  ```
* 通过模块创建子进程：
  ```python
  from multiprocessing import Process
  Process(target=None, name=None, args=(), kwargs={}, *, daemon=None)
    target: 进程工作的任务函数
    name: 进程的名字
    args: 元组为形式，不定长接受 进程工作的任务函数的参数
    kwargs：早点为形式，不定长接受 进程工作的任务函数的参数
  这样创建的子进程实例，只会工作target参数所对应的函数。
  ```
 
* 进程属性
  ```
  p = Process()
  p.start() 开启该进程
  p.pid 进程PID值，一定是在进程开启之后才能获取到
  p.name 进程名
  p.daemon=False 父进程会等待子进程退出才会退出，和守护进程经常没关系。
  p.daemon = True: 如果父进程结束，那么子进程也会结束，父进程可以不用在等待子进程结束了。
    必须在进程开启之前就要设置好
  p.join() 回收进程资源
  ```
 
  ```
  p = current_process()
  p.name
  p.pid
  p.daemon 能获取、不能修改
  ```
 
* 用multiprocessing.Process 创建僵尸进程，孤儿进程（5分钟左右），要用time模块。
