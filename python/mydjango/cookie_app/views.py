from django.shortcuts import render,HttpResponse,redirect
from django.core.urlresolvers import reverse

# Create your views here.
def set_cookie(request):
	res = HttpResponse('1')
	res.set_cookie('test','hello cookie')
	return res

def get_cookie(request):
	cookie = request.COOKIES.get('test')
	return HttpResponse(cookie)

def del_cookie(request):
	res = redirect(reverse('get_cookie'))
	res.delete_cookie('test')
	return res
