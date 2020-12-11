from django.shortcuts import render,HttpResponse,redirect
from django.core.urlresolvers import reverse

# Create your views here.
def get_user(request,name,age=None):
	msg = '''
		name:%s<br>
		age:%s<br>
	''' % (name,age)
	return HttpResponse(msg)

def index(request):
	if request.method == 'GET':
		return render(request,'url_app/index.html')

def login(request):
	if request.method == 'POST':
		username = request.POST.get('username')
		return redirect(reverse('check_user',args=(username,)))
		#return redirect(reverse('check_user',kwargs={"username":username,}))

def check_user(request,username=None):
	content = {
		"username":username,
	}
	return render(request,'url_app/check_user.html',content)