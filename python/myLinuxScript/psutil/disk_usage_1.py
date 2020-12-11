import psutil
import time

def byte2human(n=None):
	symbols = ('K','M','G','T','P')
	#K: 1024byte
	#M: 1024 *1024 byte
	prefix = {}
	for index,value in enumerate(symbols):
		#prefix[value] = 1 << (index + 1) * 10
		prefix[value] = 1024 ** (index + 1)

	for value in reversed(symbols):
		if n >= prefix[value]:
			rt = n / prefix[value]
			return '%.2f%s' % (rt, value)
	return 	'%sbyte' % n

def get_disk_use():
	for partition in psutil.disk_partitions():
		name = partition.mountpoint
		data = psutil.disk_usage(partition.mountpoint)
		total = byte2human(data.total)
		used = byte2human(data.used)
		free = byte2human(data.free)
		percent = data.percent
		temp = '%5s:\n' % name + \
			'total:%-8s\n' % total + \
			'used:%-8s\n' % used + \
			'free:%-8s\n' % free + \
			'percent:%3s%%\n' % percent
		print(temp)
		print()

def get_disk_io(t=1):
	'''
		read_count 读的次数
		write_count 写的次数
		read_bytes 读取的所有数据量 
		write_bytes 写入的所有数据量
		read_time 读花费的毫秒数
		write_time 写花费的毫秒数
		busy_time 真正的IO操作花费的时间

	'''

	start_io = psutil.disk_io_counters()
	time.sleep(t)
	end_io = psutil.disk_io_counters()

	#这一秒IO读取bytes值
	read_bytes = end_io.read_bytes - start_io.read_bytes
	#这一秒IO写入bytes值
	write_bytes = end_io.write_bytes - start_io.write_bytes
	#这一秒IO量
	tps = end_io.read_count + end_io.write_count - (start_io.read_count + start_io.write_count)

	print('Read/s:%s' % byte2human(read_bytes))
	print('Write/s:%s' % byte2human(write_bytes))
	print('tps:%s' % byte2human(tps))



def main():
	get_disk_use()
	print('*************************')

	while True:
		try:
			get_disk_io()
			print('---------------------')
		except KeyboardInterrupt:
			break

if __name__ == '__main__':
	main()