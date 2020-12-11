import paramiko

def sftp_connect(host,user,passwd):
	client = paramiko.Transport((host,22))
	try:
		client.connect(username=user,password=passwd)
	except paramiko.SSHException:
		return None
	sftp_client = paramiko.SFTPClient.from_transport(client)
	return sftp_client

def main():
	host = '192.168.240.128'
	user =  'root'
	passwd = '111111'
	sftp_client = sftp_connect(host,user,passwd)

	remotefile_path = '/root/test.txt' # 目标主机文件路径
	localfile_path = '/Users/xikai/Desktop/test.txt' # 本地主机文件路径

	#上传文件
	#sftp_client.put(localfile_path, remotefile_path) #上传本地test文件到远程
	#下载文件
	#sftp_client.get(remotefile_path, localfile_path) #下载远程test文件到本地
	
	print('查看远程目录:')
	print(sftp_client.listdir())
	print()
	print('查看文件属性:')
	print(sftp_client.lstat(remotefile_path))
	print()
	print('打开文件:')
	with sftp_client.open(remotefile_path) as f:
		print(f.read().decode())

if __name__ == '__main__':
	main()
