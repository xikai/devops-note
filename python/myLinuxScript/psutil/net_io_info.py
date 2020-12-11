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

def get_net_io():
	start_io = psutil.net_io_counters()
	time.sleep(1)
	end_io = psutil.net_io_counters()

	bytes_sent = end_io.bytes_sent - start_io.bytes_sent
	bytes_recv = end_io.bytes_recv - start_io.bytes_recv

	print('sent/s:%s' % byte2human(bytes_sent))
	print('recv/s:%s' % byte2human(bytes_recv))


def main():
	while True:
		try:
			get_net_io()
			print('---------------------')
		except KeyboardInterrupt:
			break

if __name__ == '__main__':
	main()