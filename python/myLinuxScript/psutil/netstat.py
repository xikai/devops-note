import psutil
import socket

proto_map = {
    (socket.AF_INET,socket.SOCK_DGRAM):'tcp',
    (socket.AF_INET,socket.SOCK_STREAM):'udp',
    (socket.AF_INET6,socket.SOCK_DGRAM):'tcp6',
    (socket.AF_INET6,socket.SOCK_STREAM):'udp6',
}

def get_netstat():
    temp = '%-5s %-30s %-30s %-15s %-6s %s'
    print(temp % ('协议','本地地址','远程地址','状态','PID','进程名')) #打印标题列
    proc_info = {}
    for p in psutil.process_iter(attrs=['pid','name']):
    	proc_info[p.info['pid']] = p.info['name']
    for c in psutil.net_connections():
    	laddr = '%s:%s' % c.laddr
    	raddr = ''
    	if c.raddr:
    		raddr = '%s:%s' % c.raddr
    	print(
    		temp % (
    			proto_map[(c.family,c.type)],
    			laddr,
    			raddr or '-',
    			c.status,
    			c.pid or '-',
    			proc_info.get(c.pid) or '?'
    		)
    	)


def main():
	get_netstat()

if __name__ == '__main__':
	main()