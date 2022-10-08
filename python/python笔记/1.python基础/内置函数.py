str：
str.capitalize() 			            #首字母大写
str.title()				                #字符串中每个单词首字母大写
str.casefold()				            #将字符串中大写字母转换成小写
str.center(width[, fillchar])	        #指定字符串宽度，将原字符串居中，并用指定字符填充（默认用空格）剩余宽度  'hello'.center(20,'*')
str.count()                             #统计指定字符在字符串中出现的次数 'hello'.count('l')
str.encode(encoding='UTF-8',errors='strict')   #以 encoding 指定的编码格式编码字符串 'hello'.encode('base64','strict')
str.endswith(suffix[, start[, end]])    #判断字符串是否以指定后缀结尾 可选参数"start"与"end"为检索字符串的开始与结束位置		'hello.py'.endswith('.py',5,8)
str.expandtabs([tabsize=8])             #返回字符串中的 tab 符号('\t')转为空格后生成的新字符串,默认tab为8个空格"this is\tstring example".expandtabs()
str.find(sub[, start[, end]])           #返回字符串中包含子字符串的起始索引值，不包含返回-1，start,end索引范围值可选'hello world'.find('wor',5,10)
str.rfind(sub[, start[, end]])          #返回字符串中子字符串最后一次出现的位置,如果没有匹配项则返回-1。
str.index(sub[, start[, end]])		    #和str.find一样，不包含时报错。
str.rindex(sub[, start[, end]])         #和str.rfind一样，不包含时报错。
str.isalnum()                           #检测字符串是否由字母和数字组成，且不包含空格 返回bool值 
str.isalpha()                           #检测字符串是否由字母组成，且不包含空格 返回bool值 
str.isnumeric()                         #检测字符串是否只由数字组成
str.isdecimal()                         #检测字符串是否由十进制整数组成，且不包含空格 返回bool值
str.isidentifier()                      #判断字符串是否是脚语言定义的有效字符 '&a afe'.isidentifier() //False
str.lower()                             #转换字符串中所有大写字符为小写
str.upper()                             #转换字符串中所有小写字符为大写
str.swapcase()				            #大小写互换
str.islower()                           #检测字符串里的字符是否都是小写字母
str.isupper() 				            #检测字符串里的字符是否都是大写字母
str.isprintable()                 #判断字符串所包含的字符是否全部可打印。字符串包含不可打印字符，如转义字符，将返回False
str.isspace()                     #判断字符串是否为空或空格组成
str.istitle()                     #检测字符串中所有的单词拼写首字母是否为大写,且其他字母为小写。
sep.join(iterable)                #将序列中的元素以指定的字符连接生成一个新的字符串 '-'.join('abcd')
str.split(sep=None, maxsplit=-1)  #通过指定分隔符对字符串进行切片,不指定分隔符时默认以空格作为分隔符，maxsplit指定分片数 默认最大数量 'a*b*c*d'.split('*',2)  //['a', 'b', 'c*d']
str.rsplit(sep=None, maxsplit=-1) #当指定maxsplit时，切分右边指定次数'a*b*c*d'.rsplit('*',2) //['a*b', 'c', 'd']
str.ljust(width[, fillchar])      #指定字符串的长度。原字符串左对齐，填充部分补空格或指定字符  'test'.ljust(20,'*')
str.rjust(width[, fillchar])      #同ljust相同，原字符串右对齐
str.zfill(width)                  #指定字符串的长度。原字符串右对齐，前面填充0
str.partition(sep)                #根据指定的分隔符将字符串进行分割。返回一个3元的元组，第一个为分隔符左边的子串，第二个为分隔符本身，第三个为分隔符右边串。'http://www.test.com'.partition('://')
str.rpartition(sep)		          #指定分隔符，从右边开始将字符串进行分割 'IamTom_IamTom'.rpartition('am') //('IamTom_I', 'am', 'Tom')
str.replace(old, new[, count])    #把字符串中的 old（旧字符串） 替换成 new(新字符串)，如果指定第三个参数max，则替换不超过 max 次。 'this is is me'.replace('is','IS',2)
str.strip([chars])                   #删除字符串前后的指定字符，默认为空格
str.rstrip([chars])                  #删除字符串末尾的指定字符，默认为空格          
str.splitlines([keepends])           #按换行符来分隔字符串，返回一个列表,keepends默认为False不保留换行符
str.startswith(prefix[, start[, end]])#判断字符串是否以某个字符或字符串开头的，第二个参数：起始位置，第三个参数：结束位置
str.maketrans(x, y=None, z=None, /)   #用于创建字符映射的转换表(配合translate函数使用)，对于接受两个参数的最简单的调用方式，第一个参数是字符串，表示需要转换的字符，第二个参数也是字符串，表示转换的目标。两个字符串的长度必须相同， 为一一对应的关系。有第三个参数，表示要删除的字符，也是字符串。如果只有一个参数，此时这个参数是个字典类型。
str.translate(table)                  #根据maketrans方法创建的表，进行字符替换

trantab = str.maketrans("abcde", "12345")
print ("Hello abc".translate(trantab))
//返回H5llo 123


--------------------------------------------------------------------------------
list：
l = [1,2,3,4,5]
list.append(object)                #添加对象到列表末尾 l.append(6)
list.extend(iterable)              #将iterable序列中的每一个元素扩展到列表中 l.extend('abcd')
list.insert(index, object)         #在指定索引位置插入一个元素
list.copy()			               #浅拷贝列表l.copy()
list.pop([index])                  #删除并返回索引位置的元素（默认为最后一个）
list.remove(value)                 #删除列表中第一次出现的指定值
list.clear()                       #清空列表删除所有元素l.clear()
list.count(value)                  #统计元素在列表中出现的次数l.count(1)
list.index(value, [start, [stop]]) #在列表中找出某个值第一个匹配项的索引位置。start:stop可选指定索引范围
list.reverse()                     #反转列表
list.sort(key=None, reverse=False) #列表排序 func 如果指定了该参数会使用该参数的方法进行排序。reverse=Ture时逆排序


--------------------------------------------------------------------------------
tuple：
t = ('a','b','c')
tuple.count(value)                  #统计元组中value出现的次数
tuple.index(value, [start, [stop]]) #在元组中找出某个值第一个匹配项的索引位置。start:stop可选指定索引范围


--------------------------------------------------------------------------------
dict:
d = {1:'a',2:'b',3:'c'}
dict.get(k[,d])                     #返回指定键的值,如果值不在字典中返回默认值d（默认为None）
dict.setdefault(k[,d])              #返回指定键的值,如果键不已经存在于字典中，将会添加键并将值设为默认值d（默认为None）
dict.update([E, ]**F)		        #更新或增加健值对到字典 d.update({1:'aaa',4:'e'})  //{1: 'aaa', 2: 'b', 3: 'c', 4: 'd'}
dict.fromkeys(iterable, value=None, /) #创建一个新字典,以序列iterable中元素做字典的键,value为字典所有键对应的初始值d = dict.fromkeys(range(3),'abc')
dict.items()                        #返回由键值对组成元素的列表 d.items()  //dict_items([(1, 'a'), (2, 'b'), (3, 'c')])
dict.keys()                         #以列表返回字典所有的键 d.keys()  //dict_keys([1, 2, 3])
dict.values()			            #返回字典中所有的value。 d.values()
dict.pop(k[,d])                     #删除并返回字典指定key对应的值，如果key不存在返回默认值d
dict.popitem()                      #删除并返回字典中对象健值对（默认从最后一个开始）
dict.copy()			                #浅拷贝字典d.copy()
dict.clear()                        #清空字典删除所有元素 d.clear()


--------------------------------------------------------------------------------
set:		
myset = {1,2,3,4,5}
set.add()                          #添加一个指定元素到集合 myset.add(6)
set.pop()			               #删除并返回集合中任意一个元素
set.discard()			           #从集合中删除一个指定元素，如果元素不存在则什么也不做 myset.discard(1)
set.remove()                       #从集合中删除一个指定元素，如果元素不存在则报错 myset.remove(1)
set.clear()                        #清空集合删除所有元素 myset.clear()
set.copy()			               #浅拷贝集合myset.copy()
setA.intersection(setB)            #返回两个集合的交集(setA & setB) 
setA.intersection_update(setB)     #返回两个集合的交集并更新setA
setA.union(setB)                   #返回两个集合的并集(setA | setB)
setA.update(setB)                  #返回两个集合的并集并更新setA
setA.symmetric_difference(setB)         #返回setA与setB的差集(setA ^ setB)
setA.symmetric_difference_update(setB)  #返回setA与setB的差集并更新setA
setA.difference(setB)		        #返回setA与setB中不同的元素(setA - setB) 
setA.difference_update(setB)        #返回setA与setB中不同的元素并更新setA
setA.isdisjoint(setB)               #如果两个set没有交集,返回True
setA.issubset(setB)                 #判断A集合是否是B集合的子集(setB包含setA)
setA.issuperset(setB)		        #判读A集合是否是B集合的超集(setA包含setB)



--------------------------------------------------------------------------------
系统内建函数
id()                #获取对象内存地址
type()              #获取对象类型
dir()               #函数不带参数时，返回当前范围内的变量、方法和定义的类型列。表带参数时，返回参数的属性、方法列表
help(str)           #获取模块中函数的使用帮助
hash()              #用于获取取一个对象（字符串或者数值等）的哈希值。
eval()              #执行一个字符串表达式，并返回表达式的值。
repr()              #将表达式转换成字符串
str()               #将其它类型数据转换为字符串类型
int()               #对象转换为整数类型
float()             #函数用于将整数和字符串转换成浮点数。
list()              #将对象转换为列表
tuple()             #将对象转换为元组
iter()              #将对象转换为迭代器
len()               #返回字符串长度
sum()               #求和
cmp()               #比较两个对象大小，返回正数或负数 相等返回0
all(iterable)       #判断可迭代参数 iterable 中的所有元素是否不为 0、''、False 或空返回 True，否则返回 False。
round()             #返回浮点数x的四舍六入值round(100.23456,2) 返回100.23
range(0,5)          #返回[0 1 2 3 4]
input()             #接受一个标准输入数据，返回为 string 类型。
min()               #返回给定参数的最小值
max()               #返回给定参数的最大值
sorted()            #排序
reversed()          #倒排序
enumerate()         #将一个可遍历的数据对象组合为一个索引序列，同时列出数据和数据下标，一般用在 for 循环当中。
map(function, iterable)    #根据提供的函数对指定序列做映射。
filter(function, iterable) #用于过滤序列，过滤掉不符合条件的元素，返回由符合条件元素组成的新列表。
zip()               #用来压缩数据，将多个序列对应索引位置上的值包装到一个新的元组中

