import pexpect

PROMAT = ['# ','\$ ',pexpect.TIMEOUT]
CHECK = [
	pexpect.TIMEOUT,
	pexpect.EOF,
	'Are you sure you want to continue connecting',
	'[P|p]assword:'
]

def make_connection(host, user, passwd):
	'''
		建立连接：
		第一次连接，需要确认密钥
		密码错误 password:
		连接超时 pexpect.TIMEOUT
		直接断开 EOF
	'''
	cmd = 'ssh ' + user + '@' + host  #ssh root@192.168.240.128
	child = pexpect.spawn(cmd,timeout=10)
	ret = child.expect(CHECK)

	if ret == 0:
		# 超时
		print('[-] CONNECT TIMEOUT: %S' % host)
		return
	if ret == 1:
		# 关闭
		print('[-] CONNECT CLOSE: %S' % host)
		return
	if ret == 2:
		# 确认密钥
		child.sendline('yes')
		#ret = child.pexpect(pexpect.TIMEOUT,'[P|p]assword:')

	child.sendline(passwd)
	ret = child.expect(PROMAT)

	if ret == 2:
		rint('[-] CONNECT TIMEOUT: %S' % host)
		return

	print('[+] SUCCESS LOGIN: %s' % host )
	return child

def send_cmd(child,cmd):
	child.sendline(cmd)
	child.expect(PROMAT)
	#只要有返回的索引就认为这个命令执行完毕
	print(child.before.decode())  #将返回的进制数据解码打印

def main():
	user = 'root'
	passwd = '111111'
	host = '192.168.240.128'
	child = make_connection(host, user, passwd)
	if child:
		while True:
			try:
				cmd = input('请输入系统指令：')
				send_cmd(child,cmd)
			except KeyboardInterrupt:
				break
	child.close()

if __name__ == '__main__':
	main()

