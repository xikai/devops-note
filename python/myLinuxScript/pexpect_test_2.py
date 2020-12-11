from pexpect import pxssh

def connect(host, user, passwd):
	s = pxssh.pxssh()
	s.login(host, user, passwd)
	return s

def send_cmd(s,cmd):
	s.sendline(cmd)
	s.prompt()   #自动匹配标识
	print(s.before.decode())

def main():
	user = 'root'
	passwd = '111111'
	host = '192.168.240.128'
	s = connect(host, user, passwd)
	if s:
		while True:
			try:
				cmd = input('%s@pexpect \> ' % user)
				send_cmd(s,cmd)
			except KeyboardInterrupt:
				break

if __name__ == '__main__':
	main()