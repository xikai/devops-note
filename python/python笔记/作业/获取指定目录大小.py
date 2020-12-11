import os

filesize = []
def get_file(path):
	os.chdir(path)
	objlist = os.listdir()
	for name in objlist:
		obj = os.path.join(path,name)
		if os.path.isfile(obj):
			print('%s | 文件大小：%d' % (obj, os.path.getsize(obj)))
			filesize.append(os.path.getsize(obj))
		else:
			get_file(obj)


def dir_sum():
	sig = {
		4:'TB',
		3:'GB',
		2:'MB',
		1:'KB',
		0:'byte'
	}
	dirsize = sum(filesize)

	for i in reversed(range(1,5)):
		#i=4 3 2 1
		if dirsize > 1024 ** i:
			res = dirsize / (1024 ** i)
			break
		else:
			i = 0
			res = dirsize
	print('文件夹大小:%.2f %s' % (res,sig[i]))



get_file('f:\pysalt')
dir_sum()