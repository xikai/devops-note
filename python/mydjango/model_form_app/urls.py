from django.conf.urls import include, url
from . import views

urlpatterns = [
	url(r'^index/', views.index),
	url(r'^index2/', views.index2),
	url(r'^index3/', views.index3),
]