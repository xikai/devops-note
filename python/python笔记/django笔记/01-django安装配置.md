# Django框架

### django的来源音乐家
 
* django 瑞哈德，2003美国，制作新闻站点，05年，django获的了BSD许可证
* 优雅，的WEB的框架
* 文档：非常健全的中文文档
 
---------
 
* 数据库访问组件：
  * django中model层自带的数据库访问方式，可以兼容目前市面上各大数据库
* URL路由映射技术
  * 强大的媒婆技术，可以让你优雅的设计连接
* 管理界面：
  * admin界面，可视化数据库管理系统
* 调试信息
 
----------
 
### django的结构
 
* MVT架构
  * M（Model）：数据库
  * T（Template）：前端模板
  * V（Views）：控制器/视图/媒婆
    * 响应request
    * 返回reponse
* 模型层：Model
* 视图层：View
* 路由设计：urls
* 模板层：Template
* 表单层：Django提供了一套数据字段转换表单字段的系统
  * CharField(defualt)
 
### 开启django
 
* django 1.8.2 
* 安装django：pip3 install django==1.8.2 -i https://pypi.tuna.tsinghua.edu.cn/simple
  * 16年的时：1.4版本
    * django：1.8.2
 
### 创建django项目
 
    > django-admin startproject first_learn
 
### 框架目录
 
```python
./first_learn #容纳整个项目文件
    ./first_learn #项目的配置文件夹 主控目录
        __init__.py #声明当前的文件夹可以做为模块导入
        settings.py #整个项目的配置文件
        urls.py #整个框架项目的主要路由文件
        wsgi.py #项目发布时所需
    manage.py #当前项目的命令行管理工具
```
 
### django测试开发服务器
 
* 查看项目的样子：python manage.py runserver 0.0.0.0:80
 
  * 关闭服务：ctrl + c
 
* 测试服务器：压力承载特别小。
 
  ```python
  It worked!
  Congratulations on your first Django-powered page.
  ```
 
###  时区及语言设置
 
* setting.py
 
```python
LANGUAGE_CODE = 'zh-Hans'
TIME_ZONE = 'Asia/Shanghai'
```
 
* 检查是否修改正确
  * 首页是否改变
  * 127.0.0.1/admin/ 后台数据库管理界面是否变化
 
### APP的创建
 
    > python manage.py startapp people
 
* app承载真正功能的实现
 
* app目录结构：
 
  * ```
    people
        __init__.py
        admin.py #当前app如果使用了数据库，数据表可以在这个文件下进行注册，
        models.py #创建django所使用的数据表
        test.py  #单元驱动测试
        views.py #真正业务函数的编写
    ```
 
### 第一个app应用
 
 * 视图函数：
 
 * ```python
   ./123/people/views.py
   from django.shortcuts import render,HttpResponse
   def index(request):
    #request: django中的视图函数 第一个参数往往是request
    return HttpResponse('我想写一个字符串') #返回一个字符串 Response
   ```
 
 * 为视图函数设置路由关系：
 
 * ```python
   ./123/first_learn/urls.py
   from django.conf.urls import include, url
   from django.contrib import admin
   from people import views
   urlpatterns = [
       url(r'^admin/', include(admin.site.urls)),  #127.0.0.1/admin/
       url(r'^index/', views.index),  #127.0.0.1/index/
   ]
   ```
 
 * 一个功能对应一个路由，一个路由又对应一个视图函数
 
    * 一个连接对应一个视图函数
 
### 不同app对应不同的路由文件
 
* people：
  * 在app文件夹下创建：urls.py
 
* airticle：
  * 在app文件夹下创建：urls.py
 
* 需要你手动的在app下创建新的urls.py路由映射文件
 
  * 查找的顺序
 
    * ```powershell
      1：主控路由文件：123/first_learn/urls.py
      2：找到对应app的路由文件 123/people/urls.py
      3：对用app路由文件找到真正的视图函数：123/people/views.py
      ```