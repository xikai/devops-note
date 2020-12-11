**os.name判断现在正在实用的平台，Windows 返回 ‘nt'; Linux 返回’posix'**
```
>>> os.name
'nt'
```

**os.system调用系统命令**
```
>>> os.system('dir')
 驱动器 F 中的卷没有标签。
 卷的序列号是 000A-ECC3

 f:\ssl 的目录

2018/05/28  14:54    <DIR>          .
2018/05/28  14:54    <DIR>          ..
2018/05/28  14:54    <DIR>          aaa
2018/05/28  14:52    <DIR>          abc
2017/05/09  10:08    <DIR>          bak
2017/02/22  11:20    <DIR>          ikayaa
2017/03/08  18:29    <DIR>          interouge
2017/02/22  09:17    <DIR>          www.interouge.com
               0 个文件              0 字节
               8 个目录 167,592,112,128 可用字节
0
```

**os.getcwd获取当前所在路径**
```
>>> os.getcwd()
'C:\\Users\\Administrator'
```

**os.listdir返回指定路径下的所有文件目录,默认返回当前所在目录**
```
>>> os.listdir()
['.git', 'pillar', 'README.md', 'salt']
>>> os.listdir('c:\python36')
['DLLs', 'Doc', 'include', 'Lib', 'libs', 'LICENSE.txt', 'NEWS.txt', 'python.exe
', 'python3.dll', 'python36.dll', 'pythonw.exe', 'Scripts', 'tcl', 'Tools', 'vcr
untime140.dll']
```

**os.remove删除指定文件**
```
>>> os.listdir()
['bak', 'ikayaa', 'interouge', 'www.interouge.com', '深圳市通拓科技有限公司合同.
pdf']
>>> os.remove('深圳市通拓科技有限公司合同.pdf')
>>> os.listdir()
['bak', 'ikayaa', 'interouge', 'www.interouge.com']
>>> os.remove('ikayaa') 
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
PermissionError: [WinError 5] 拒绝访问。: 'ikayaa'
```

**os.rmdir删除指定空目录**
```
>>> os.rmdir('ikayaa')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
OSError: [WinError 145] 目录不是空的。: 'ikayaa'
>>> os.rmdir('abcem')
>>>
```

**os.mkdir创建目录**
```
>>> os.mkdir('abc')
>>> os.listdir()
['abc', 'bak', 'ikayaa', 'interouge', 'www.interouge.com']
>>> os.mkdir('aaa\bbb')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
OSError: [WinError 123] 文件名、目录名或卷标语法不正确。: 'aaa\x08bb'
```

**os.makedirs递归创建目录**
```
>>> os.makedirs('aaa/bbb')
>>> os.listdir()
['aaa', 'abc', 'bak', 'ikayaa', 'interouge', 'www.interouge.com']
>>> os.listdir('aaa')
['bbb']
```

**os.chdir切换目录到指定目录**
```
>>> os.getcwd()
'f:\\ssl'
>>> os.chdir('c:\python36')
>>> os.getcwd()
'c:\\python36'
>>>
```

**os.path.isfile判断指定对象是否为文件。是返回True,否则False**
```
>>> os.path.isfile('aaa')
False
```

**os.path.isdir判断指定对象是否为目录。是True,否则False**
```
>>> os.path.isdir('aaa')
True
```

**os.path.exists()——检验指定的对象是否存在。是True,否则False**
```
>>> os.path.exists('server.key')
False
```

**os.path.basename返回指定路径文件名**
```
>>> os.path.basename('f:\ssl\ikayaa\server_interouge.key')
'server_interouge.key'
```

**os.path.dirname返回指定路径目录名**
```
>>> os.path.dirname('f:\ssl\ikayaa\server_interouge.key')
'f:\\ssl\\ikayaa'
```

**os.path.abspath返回指定文件的绝对路径，不论文件是否存在**
```
>>> os.getcwd()
'f:\\ssl\\interouge'
>>> os.listdir()
['certreq.csr', 'server_interouge.key', 'server_interouge.pem', '合同扫描.pdf']
>>> os.path.abspath('certreq.csr')
'f:\\ssl\\interouge\\certreq.csr'
>>> os.path.abspath('abdeddf')
'f:\\ssl\\interouge\\abdeddf'
```

**os.path.join(path, name)——连接目录和文件**
```
>>> os.path.join('c:/123/','abc')
'c:/123/abc'
>>> os.path.join('c:\\456','abc')
'c:\\456\\abc'
```

**os.path.split将指定路径分隔返回路径的目录和文件名**
```
>>> os.path.split('c:/456/abc')
('c:/456', 'abc')
```

**os.path.getsize获得文件的大小 单位byte(字节)，如果为目录，返回4096。**
```
>>> os.path.getsize('合同扫描.pdf')
1936051
>>> os.path.getsize('f:/ssl')
4096
>>> os.path.getsize('c:\\python36')
4096
>>>
```