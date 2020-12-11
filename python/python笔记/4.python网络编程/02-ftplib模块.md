### ftplib模块
 
* ISO认证：国际标准组织
  * RFC
 
* https://docs.python.org/3/library/ftplib.html
* ftplib：自带的模块，直接通过该模块与FTP服务器进行交互
  * ftp = fiplib.FTP(*host=''*, *user=''*, *passwd=''*, *acct=''*, *timeout=None*, *source_address=None* )
  * 初始化一个FTP对象
    * host：FTP服务地址，默认为空字符串
    * user：账号
    * passwd：登录秘密
    * acct：额外登录
    * timeout：超时选项
    * source_address：来源地址。(ip,port)
  * ftp = FTP()
    * ftp.connect(host,timeout,source_address) 
      * 连接ftp服务器
    * ftp.login(user,passwd)
      * 登录验证ftp服务器
    * ftp.set_debuglevel(2) 调试级别的设置
      * 调试级别：
        * 0：不输出任何内容
        * 1：单行输出请求响应
        * 2：输出全部过程
    * ftp.retrlines(cmd,callback)
      * CMD：传输命令
        * 如果我希望查看文件列表，
          * LIST：详细信息展示，ls命令查看到的
          * NLST：只返回文件名
      * callback：
        * 默认的callback是向标准输出打印结果
          * 只是把结果print了
    * 进入指定目录：
      * 默认进入的是/var/ftp目录
      * 进入到pub目录下
    * ftp.cwd(pathname)：
      * 设置我当前在ftp服务器的目录为pathname

### 上传文件
 
 * FTP.storbinary(cmd,fp,blocksize=8192,callback=None)：
   * 二进制上传数据
     * 不在乎文件的编码格式。
   * cmd：'STOR filename'
   * fp：二进制模式打开的文件对象，未来会被上传
   * blocksize：块大小，
   * callback：回调函数
* FTP.storlines(cmd, fp,callback=None)
  * Ascii模式上传文件
  * cmd：'STOR filename'
* 不管你用的是什么方式，打开的 文件都必须是二进制
 
### 下载文件
 
* FTP.retrlines(cmd,callback)
  * Ascii模式下载文件
  * cmd:'RETR ' + remote_filename 
  * callback：每一次传输的数据，该怎么做
    * 读到的数据 激活callback
    * 并且读到的数据，作为参数传递给callback
    * 回调函数
* FTP.retrbinary(cmd,callback)
  * 二进制模式下载文件
  * cmd:'RETR ' + remote_filename 
  * callback：每一次传输的数据，该怎么做
    - 读到的数据 激活callback
    - 并且读到的数据，作为参数传递给callback
    - 回调函数
* 二进制模式下载文件，回调写入函数的文件对象一定是具有二进制打开属性的
  * 二进制下载支持编码下载
  * ascii下载，只支持ascii可以解释的下载

```python
from ftplib import FTP
def ftp_(host,user='anonymous',passwd=''):
    #ftp = FTP(host,user,passwd)
    '''
        连接ftp
    '''
    try:
        ftp = FTP()
        ftp.set_debuglevel(2) #设置连接时响应的调试级别
        ftp.connect(host)
        ftp.login(user,passwd)
    except Exception:
        ftp = None
    else:
        ftp.cwd('pub/')
    return ftp
     
def get_ftp_list(ftp):
    if not ftp:
        return
    '''
        获取FTP服务器上的文件及文件夹信息
    '''
    #cmd = 'NLST'
    cmd = 'LIST'
    file_dict = {}
    sig = {
        'd':'dir',
        '-':'file',
        'b':'block',
    }
    def get_file(filename):
        file_sig = filename[0] #取出文件标示
        file_name = filename.split(' ')[-1]
        file_dict[file_name] = sig[file_sig]
 
    try:
        ftp.retrlines(cmd,get_file)
    except Exception:
        file_dict = None
    return file_dict
 
def upload_file_binary(ftp,filename):
    '''
        二进制上传文件
        STOR 1.txt
    '''
    cmd = 'STOR ' + filename
    with open(filename,'rb') as fp:
        ftp.storbinary(cmd,fp)
  
def upload_file_lines(ftp,filename):
    cmd = 'STOR ' + filename
    with open(filename,'rb') as fp:
        ftp.storbinary(cmd,fp)
 
 
def download_file_lines(ftp,filename):
    '''
        Ascii
    '''
    cmd = 'RETR ' + filename 
    with open(filename,'w',encoding='utf-8') as fp:
        ftp.retrlines(cmd,fp.write)
 
def download_file_binary(ftp,filename):
    '''
        Binary
    '''
    cmd = 'RETR ' + filename 
    with open(filename,'wb') as fp:
        ftp.retrbinary(cmd,fp.write)
 

def main():
    host = '192.168.1.104'
    ftp = ftp_(host)
    filename = 'Hi'
    download_file_binary(ftp, filename)
if __name__ == '__main__':
    main()
```