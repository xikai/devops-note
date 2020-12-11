### 静态路由
 
* 匹配流程：
 
  * 1：urls.py文件下
  * 2：查找全局变量：urlpatterns
    * urlpatterns：列表，url函数的实例
  * 3：从上到下进行匹配，找到一个匹配
    * 继续去拿取到对应的视图函数
  * 4：匹配不到：404错误
 
* url(regex,view,prefix,name)
 
  * regex：路由映射关系的匹配正则
 
  * view：对应的视图函数，
 
    * 1：直接是一个导入的视图函数
    * 2：视图函数的路径字符串
 
  * prefix：路径前缀，声明当前指明视图函数路径字符串是属于哪个app的
 
  * name：为映射关系，起别名，
 
    * url(r'/iamhandsome',name="handsome")
 
    * ```
      def func(request):
        redirect(reverse('handsome'))
      ```
 
### 未命名动态路由
 
 * 可以吧一些参数放到连接里，而不是以get形式传参
 
* 1：构建视图函数，视图函数按照顺序位置定义参数
 
* 2：路由映射中根据顺序 以一定的正则匹配方式 用括号包装参数
 
* 3：如果映射匹配，那么连接中的参数会作为视图函数的参数
 
  * 直接把要传递的东西放到连接里
 
* 连接中的参数全部都是字符串，虽然判断的时候是有类型的。
 
  * ```python
    url(r'^get_user/([a-z]+)/(\d+)/',get_user),
    ```
 
  * ```python
    def get_user(request,name,age):
        name: ([a-z]+)
        age: (\d+)
    ```
 
  
 
### 命名动态路由
 
* 之前的连接传递顺序是靠顺序
  * 命名传参
 
  * ```python
    def func(a,b):
        pass
    func(b=1,a=2)
    ```
 
  * ```python
    (?P<变量名>patterns)
    url(r'^get_user/(?P<age>\d+)/(?P<name>[a-z]+)/',get_user),
    ```
 
  * ```python
    def index(request,name,age):
        name : (?P<name>[a-z]+)
        age : (?P<age>\d+)
    ```
 
 
### 路由反向解析
 
* from django.core.urlresolvers import reverse
 
* reverse：接收一个name值重命名的变量，解析该变量，获取到对应的路由映射
 
  * args：按顺序以元祖为形式为连接传参
  * kwargs：为命名路由传参，字典格式
 
* 视图函数：
     ```python
    reverse("name",args=,kwargs=)
    ```
 
* 模板页面：
    ```html
    {% url "name" a1 a2 %}
    {% url "name" name=xx age=xx %}
    <a href="{% url "get_user" age=20 name="abc" %}">get_user</a>
    ```
    
### 命名空间
* 为每一个app下的urls.py 里面的所有内容 取一个空间名
```python
url(r'^url_app/', include("url_app.urls",namespace="app1")),
url(r'^url_app_2/', include("url_app_2.urls",namespace="app2")),
```
 
```html
<a href="{% url "app1:index" %}" >index_1</a>
<a href="{% url "app2:index" %}" >index_2</a>
```
 
```python
reverse("app1:check_user",args=(username,))
```