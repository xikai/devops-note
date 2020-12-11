from django import forms
from model_form_app.models import TestTable

class TestTableForm(forms.Form):
	name = forms.CharField(max_length=10,required=False)

class TestForm(forms.ModelForm):
	class Meta:
		#这个表单类为哪个模型类工作
		model = TestTable
		fields = ['name']

		error_messages = {
			'name':{
				'required':'必须要填',
				'max_length':'写这么长干啥'
			}
		}

		help_texts = {
			'name':'名字不能叫小红'
		}