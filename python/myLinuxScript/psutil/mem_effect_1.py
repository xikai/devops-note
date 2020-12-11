import psutil

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

def get_mem_use():
	rt = psutil.virtual_memory()
	for name in rt._fields:
		if name != 'precent':
			value = byte2human(getattr(rt,name))
			print('%10s : %7s' % (name,value))
		else:
			print('%10s : %6s%%' % (name, getattr(rt,name)))


def get_swap_use():
	rt = psutil.swap_memory()
	for name in rt._fields:
		if name != 'precent':
			value = byte2human(getattr(rt,name))
			print('%10s : %7s' % (name,value))
		else:
			print('%10s : %6s%%' % (name, getattr(rt,name)))

def main():
	print('get_swap_use:')
	get_swap_use()
	print('---------------')
	print('get_mem_use:')
	get_mem_use()

if __name__ == '__main__':
	main()
	byte2human(111)