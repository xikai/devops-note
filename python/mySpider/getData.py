from download import download
import re
import bs4


def get_ca_words(html):
	'''
		<meta name="keywords" content="(.*?)" />
	'''
	content = re.findall('<meta name="keywords" content="(.*?)" />', html)[0]
	return content.split('(+)')[-1]

def get_mag_info(html):
	'''
		杂志名，h3标签中 唯一标签
		杂志等级，h3标签中
	'''
	tags = [
			'主管单位','主办单位',
			'国际刊号','国内刊号',
			'出版地方','邮发代号',
			'创刊时间','发行周期',
			'业务类型'  
	]
	mag_info = {}
	bs4_ = bs4.BeautifulSoup(html,'html.parser')
	title = bs4_.h3.contents[0].strip()
	level = bs4_.h3.contents[1].get_text().strip()
	img = 'https:' + bs4_.find('div',{'class':'preview'}).img.attrs['src']

	mag_info['杂志连接'] = url
	mag_info['杂志图片'] = img
	mag_info['杂志名'] = title
	mag_info['杂志等级'] = level
	
	content = bs4_.find('ul',{'class':'after-clear'}).findAll('li') #取到每一个li标签
	
	for i,tag in enumerate(tags):
		res = content[i].get_text().split('：')[-1].strip()
		mag_info[tag] = res if res else '暂无结果'	 
	return mag_info