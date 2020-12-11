import paramiko

def ssh_connect(host,user,pk_file):
	client = paramiko.SSHClient()
	client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
	try:
		client.connect(host,username=user,pkey=pk_file)
	except paramiko.SSHException:
		return None
	return client


def exec_cmd(client,cmd):
	stdin,stdout,stderr = client.exec_command(cmd)
	return stdout.read().decode(),stderr.read().decode()

def main():
	host = '192.168.240.128'
	user =  'root'
	pk_file = paramiko.RSAKey.from_private_key_file('/Users/xikai/.ssh/id_rsa') #创建私钥对象
	client = ssh_connect(host,user,pk_file)
	client.invoke_shell()
	if client:
		cmd = input('%s@pexpect \> ' % user)
		res = exec_cmd(client,cmd)
		if res[0]: #代表有正常的命令执行结果输出
			print(res[0])
		if res[-1]: #代表有命令有错误的输出
			print(res[-1])
	client.close()


if __name__ == '__main__':
	main()