import os
# import sys
# sys.setrecursionlimit(10000)

class OsFunc:
    def __init__(self):
        self.file_list = [] #保存获取到的文件个数列表
        self.dir_list = [] #保存获取到的文件夹个数列表
        self.file_size = {} #key: 文件名  value: 文件大小
    #实现统计目录下有效文件个数，
 
    #人性化输出单位大小
    def byte2human(self,num):
        sig = ['K','M','G','T','P','E','Z','Y']
        symbol = {} #key:单位  value:对应的byte大小
            #{k:1024,M:1024*1024,G:1024*1024*1024}
        # 1K : 1024 byte
        # 1M : 1024 * 1024byte
        # 1G : 1024 * 1024 *1024 byte
        for i,s in enumerate(sig): #enumerate 1:第一个返回索引，2:返回索引的值
            #i: 0,1,2,3,4
            #s: k,m,g,t,p,
            symbol[s] = 1024 ** (i + 1) #求出对应单位的byte大小
            #symbol[s] = 1 << 10 * (i + 1)
        if num < 1024:
            return '%.2fbytes' % num
        else:
            for v in reversed(sig): #reversed 逆置列表
                if num > symbol[v]: #判断这个数字 是否大于对应单位的大小
                    result = num / symbol[v]
                    return '%.2f%s' % (result,v)
 
    #获取文件个数
    def get_file_num(self,path):
        '''
            获取对应路径下有效文件个数
            path: 获取路径
            return: 对应路径下文件个数(包含嵌套目录下文件及隐藏文件)
        '''
        if os.path.exists(path):
            for name in os.listdir(path): #遍历路径
                name = os.path.join(path,name) #拼接绝对路径
                if os.path.isdir(name): #判断文件夹
                    #--------------
                    self.get_file_num(name) #进入到一个新的路径 继续判断
                    #--------------
                elif os.path.isfile(name): #判断文件
                    self.file_list.append(name) #遇到文件，追加到file_list列表中
            else:
                return len(self.file_list)
        else:
            raise TypeError('无效的路径输入!') #在用户输入错误的时候跑出异常
 
    #获取文件夹大小
    def get_dir_size(self,path):
        '''
            获取对应路径下文件夹大小
            path: 获取路径
            return: 返回对应文件夹大小
        '''
        if os.path.exists(path):
            for name in os.listdir(path): #遍历路径
                name = os.path.join(path,name) #拼接绝对路径
                if os.path.isdir(name): #判断文件夹
                    self.get_dir_size(name) #进入到一个新的路径 继续判断
                elif os.path.isfile(name): #判断文件
                    size = os.path.getsize(name) #获取到这个文件的大小
                    self.file_size[name] = size #将文件及对应大小组合成字典
            else:
                num = sum( [self.file_size[name] for name in self.file_size] ) #value值都拿出来，然后加起来
                result = self.byte2human(num) #调用类中函数 处理数字
                return result # 单位大小字符串
        else:
            raise TypeError('无效的路径输入!') #在用户输入错误的时候跑出异常
 
    #递归删除文件夹
    def rec_remove_dir(self,path):
        '''
            递归删除文件夹
            path: 要删除的文件夹
        '''
        if os.path.exists(path) and os.path.isdir(path):
            for name in os.listdir(path): #遍历路径
                name = os.path.join(path,name) #拼接绝对路径
                print(name)
                if os.path.isdir(name): #判断文件夹
                    self.rec_remove_dir(name) #进入到一个新的路径 继续判断
                elif os.path.isfile(name): #判断文件
                    print('被删除文件:',name)
                    os.remove(name)
            else: #递归结束 for循环
                print('被删除文件夹',path)
                os.rmdir(path) #里面的文件都删除了，那么接着把文件夹删除
        else:
            raise TypeError('无效的路径输入!') #在用户输入错误的时候跑出异常
 
osfunc = OsFunc()
path = input('请输入路径:')
osfunc.rec_remove_dir(path)