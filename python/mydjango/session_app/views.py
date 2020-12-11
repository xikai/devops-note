from django.shortcuts import render,HttpResponse

# Create your views here.
def set_session(request):
	if request.session.get('session_test'):
		return HttpResponse('这是一个设置好的session_test')
	else:
		request.session['session_test'] = '设置一个sesson_test'
		request.session.set_expiry(0)
		return HttpResponse('这是第一次设置session_test')

def get_session(request):
	value = request.session.get('session_test')
	if value:
		session_key = request.session.session_key
		session_expire = request.session.get_expiry_age()
		return HttpResponse(session_expire)

def del_session(request):
	pass