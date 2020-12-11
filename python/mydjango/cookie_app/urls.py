from django.conf.urls import include, url
from . import views

urlpatterns = [
	url(r'^set_cookie/', views.set_cookie),
	url(r'^get_cookie/', views.get_cookie,name='get_cookie'),
	url(r'^del_cookie/', views.del_cookie),
]