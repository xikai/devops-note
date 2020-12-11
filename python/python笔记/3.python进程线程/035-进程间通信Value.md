### Value(共享变量)
 
* 类似Array的共享数组
 
* 共享内存
 
  ``` python
  有符号的 int类型  i 
  ```
 
*  from multiprocessing import Value
 
  * Value(typecode_or_type, *args, lock=True)
    * typecode_or_type：当前的数据类型 i
    * args: 为当前的value分配默认值的
 
* v = Value('i',0)
 
  * v.value  获取到这个值
  * v.value = xxx  修改这个共享数据
 
### Value_共享内存通信
```python
from multiprocessing import Value,Process,current_process
def func_A(v):
    print('我是:%s,我拿到了:%s' % (current_process().name,v.value))
    v.value = 111
    print('我是:%s,我修改了这个数据:%s' % (current_process().name,v.value))
 
def func_B(v):
    print('我是:%s,我拿到了:%s' % (current_process().name,v.value))
    v.value = 222
    print('我是:%s,我修改了这个数据:%s' % (current_process().name,v.value))
 
def main():
    v = Value('i',0)
    #i: 有符号的整型
    p_a = Process(target=func_A,name='A',args=(v,))
    p_b = Process(target=func_B,name='B',args=(v,))
 
    p_a.start()
    p_b.start()
 
    p_a.join()
    p_b.join()
    print('我是父进程,拿到的value是:',v.value)
 
if __name__ == '__main__':
    main()

```