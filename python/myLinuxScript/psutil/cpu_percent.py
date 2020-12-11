import psutil

def main():
	try:
		while True:
			#rt = psutil.cpu_percent(1)
			#print('%.2f%%' % rt)
			rt = psutil.cpu_times_percent(1)
			print(rt)
	except KeyboardInterrupt:
		print('over...')

if __name__ == '__main__':
	main()