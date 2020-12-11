from django.conf.urls import include, url
from django.contrib import admin
from url_app.views import get_user,index,login,check_user
from template_app.views import test
from model_app.views import *

urlpatterns = [
    url(r'^admin/', include(admin.site.urls)),
    url(r'^get_user/(\w+)/(\d+)/',get_user),
    #url(r'^get_user/(?P<name>\w+)/(?P<age>\d+)/',get_user),
    url(r'^url_app/index/',index),
    url(r'^url_app/login/',login,name="login"),
    url(r'^url_app/check_user/(\w+)',check_user,name="check_user"),
    url(r'^template_app/test/',test),
    url(r'^model_app/', include('model_app.urls')),
    url(r'^form_app/', include('form_app.urls')),
    url(r'^model_form_app/', include('model_form_app.urls')),
    url(r'^cookie_app/', include('cookie_app.urls')),
    url(r'^session_app/', include('session_app.urls')),
    url(r'^', include('people.urls')),

]
