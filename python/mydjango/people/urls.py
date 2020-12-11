from django.conf.urls import include, url
from . import views

urlpatterns = [
	url(r'^$', views.index),
    url(r'^login/', views.login),
    url(r'^register/', views.register), 
    url(r'^userinfo/', views.userinfo),
]
