from django import forms
from django.forms.extras import SelectDateWidget

class PersonForm(forms.Form):
	'''
		表单类
	'''
	CHOICE = (
		('man','男'),
		('woman','女'),
		('gay','基'),
	)
	YEARS = reversed(range(1990,2000))

	Boolean = forms.BooleanField(required=False)
	Char = forms.CharField(widget=forms.PasswordInput())
	Choice = forms.ChoiceField(choices=CHOICE)
	Date = forms.DateField(widget=SelectDateWidget(years=YEARS,))
	DateTime = forms.DateTimeField()
	Email = forms.EmailField()
	Float = forms.FloatField()
	Integer = forms.IntegerField()
	IP = forms.GenericIPAddressField()