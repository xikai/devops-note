from urllib.request import urlopen,Request
from urllib.error import HTTPError,URLError
import chardet
import zlib
import re

def get_links(html):
	'''
		取出网页的所有连接
	'''
	regex = re.compile('<a[^>]+href=["\'](.*?)["\']',re.IGNORECASE)
	return regex.findall(html) #从html中查找所有a标签连接

def download(url,retry_times=2):
	'''
		返回HTML字符串
	'''
	try:
		headers = {
			'User-Agent':'BaiduSpider',
			'Accept-Encoding':''
		}
		request = Request(url,headers=headers)
		html = urlopen(request).read()
	except HTTPError as e:
		print('[HTTPError] %s' % url)
		html = None
		if retry_times > 0:
			print('[+] Retry Download %d times...' % (3 - retry_times))
			if hasattr(e, 'code') and 500 <= e.code <= 600:
				html = download(url,retry_times-1)
	except URLError as e:
		html = None
		print('[URLError] %s' % url)

	if html:
		html = html.decode( chardet.detect(html).get('encoding') if chardet.detect(html).get('encoding') else 'utf-8' )
	return html