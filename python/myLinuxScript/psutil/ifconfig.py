import psutil
import socket

af_map = {
    socket.AF_INET:'IPv4',
    socket.AF_INET6:'IPv6',
    psutil.AF_LINK:'Mac',
}

duplex_map = {
    psutil.NIC_DUPLEX_UNKNOWN:'?',
    psutil.NIC_DUPLEX_FULL:'Full',
    psutil.NIC_DUPLEX_HALF:'Half',
}


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

def get_net_info():
	stats = psutil.net_if_stats()
	addrs = psutil.net_if_addrs()

	for device,addr in addrs.items():
		print('%s:' % device)
		print('-----------------')
		if device in stats:
			device_stat = stats[device]
			print('状态：')
			print('  isup=%s | duplex=%s | speed=%sMB | mtu=%s ' % 
				(device_stat.isup,duplex_map[device_stat.duplex],device_stat.speed,device_stat.mtu)
				)
			print('地址信息：')
			for ad in addr:
				print('  family     : %s' % af_map.get(ad.family))
				if ad.address:
					print('  address    : %s' % ad.address)
				if ad.broadcast:
					print('  broadcast  : %-10s' % ad.broadcast)
				if ad.netmask:
					print('  netmask    : %-10s' % ad.netmask)
				if ad.ptp:
					print('  ptp    : %-10s' % ad.ptp)
		print()


def main():
	get_net_info()

if __name__ == '__main__':
	main()