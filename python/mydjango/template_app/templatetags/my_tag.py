from django import template
import datetime

register = template.Library()

@register.simple_tag(name="strtoupper")
def str_to_upper(value):
	return value.upper()

@register.simple_tag(takes_context=True)
def context_all(context):
	#print(context)
	#return context
	return context['myint2']

@register.assignment_tag
def current_time():
	var = datetime.datetime.now().strftime("%Y-%m-%d")
	return var