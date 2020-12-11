from django.shortcuts import render,HttpResponse,redirect
from . import models

# Create your views here.
def index(request):
	data_ = models.Account.objects.all()[0]
	product_ = models.Product.objects.all()
	user_ = models.User.objects.all()
	content = {
		'data':data_,
		'product_data':product_,
		'user_data':user_
	}
	return render(request,'people/index.html',content)


def login(request):
	if request.method == 'GET':  #如果请求是GET方式 则返回登陆页面
		return render(request,'people/login.html')
	elif request.method == 'POST': #如果请求是POST方式 则获取POST数据，验证帐号密码
		#捕捉用户发来的数据
		
		post_username = request.POST.get('username')
		post_password = request.POST.get('password')

		try:
			models.User.objects.get(username=post_username,password=post_password)
		except Exception:
			#return register(request)
			return redirect('/register/')
		else:
			#return index(request)
			return redirect('/')

def register(request):
	if request.method == 'GET': 
		return render(request,'people/register.html')
	elif request.method == 'POST': #如果请求是POST方式 则获取POST数据，验证帐号密码
		#捕捉用户发来的数据
		post_username = request.POST.get('username')
		post_password = request.POST.get('password')

		try:
			models.User.objects.get(username=post_username,password=post_password)
		except Exception:
			models.User.objects.create(username=post_username,password=post_password)
			return redirect('/')
		else:
			return HttpResponse('有这个账号密码了。') #登录成功


def userinfo(request):
	content = {
		'var':"用户变量",
	}
	return render(request,'people/userInfo.html',content)