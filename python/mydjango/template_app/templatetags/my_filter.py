from django import template
from django.utils.safestring import mark_safe

register = template.Library()

@register.filter
def my_add_str(value,arg):
	if value and arg:
		return str(value) + str(arg)
	return ''
#为过滤器函数取别名
register.filter('myadd',my_add_str)

@register.filter(name='newcenter')
def center(value, arg):
    return mark_safe(value.center(int(arg)).replace(' ','&nbsp'))