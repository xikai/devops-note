import psutil
from time import sleep

def get_cpu_percent(t=1,):
	'''
		get cpu percent
		t: 时间间隔
	'''
	t_start =  psutil.cpu_times()
	sleep(t)
	t_end = psutil.cpu_times()

	#计算所有CPU时间和
	t_start_all = sum(t_start)
	t_end_all = sum(t_end)

	#开始和结束的CPU非空闲时间
	t_start_busy =  t_start_all - t_start.idle
	t_end_busy =  t_end_all - t_end.idle

	#当前CPU非空闲时间总和
	busy_ = t_end_busy - t_end_busy
	#当前CPU所有时间
	all_ = t_end_all - t_start_all


	print('%.2f%%' % ((busy_ / all_) * 100))

def main():
	try:
		while True:
			get_cpu_percent()
	except KeyboardInterrupt:
		print('over...')

if __name__ == '__main__':
	main()