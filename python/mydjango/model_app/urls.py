from django.conf.urls import include, url
from . import views

urlpatterns = [
	url(r'^crud_create/', views.crud_create),
	url(r'^crud_get/', views.crud_get),
	url(r'^crud_update/', views.crud_update),
	url(r'^crud_all/', views.crud_all),
	url(r'^crud_filter/', views.crud_filter),
	url(r'^crud_filter2/', views.crud_filter2),
	url(r'^crud_filter3/', views.crud_filter3),
]
