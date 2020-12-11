import re
from download import download,get_links
import bs4
from settings import url,REGEX_CA #加载配置
from getData import get_ca_words,get_mag_info
from dataSQL import create_sql_connecnt,sql_ca,sql_mag
def link_crawler(home_url,regex_ca):
    '''
        获得汇总数据
    '''
    links = get_links(download(home_url)) #这个网页的所有连接
    ca_links = [] #分类连接
    db,cursor = create_sql_connecnt()
 
    #---------分类连接--------
    for link in set(links):
        if re.match(REGEX_CA, link):
            ca_links.append('https:' + link)
    #------------------------
 
    #---------分类连接下的杂志连接获取----------
    ca_dict = {} 
        #key: (分类连接,分类名词)
        #value: 分类下的杂志连接
    mag_class_id = 1
    for ca_link in ca_links: #ca_link： 分类连接
        '''
            拿出每一个分类连接
            分类连接继续获取里面想要的连接
 
        '''
        dit_url = [] #保存当前分类下连接
         
        html = download(ca_link) #分类连接下的页面HTML内容
        ca_words = get_ca_words(html)
 
        print('杂志分类 [%s]:%s' % (ca_words,ca_link))
        sql_ca(ca_words,db,cursor)
 
        bs4_ = bs4.BeautifulSoup(html,'html.parser') #初始化HTML页面数据，加工一下
        each_lag = bs4_.find('ul',{'class':'list-ul'}).findAll('li',{'class':'list-li'})
        for lag in each_lag:
            url = 'https:' + lag.find('div',{'class':'list-l'}).a.attrs['href']
            html = download(url)
            print('正在处理详情页:%s' % (url))
            mag_info = get_mag_info(url, html)
            dit_url.append(mag_info)
            sql_mag(mag_class_id,db,cursor,mag_info)
        ca_dict[(ca_link,ca_words)] = dit_url
        mag_class_id += 1
    db.close()
 
def main():
    link_crawler(url,REGEX_CA)
 
if __name__ == '__main__':
    main()