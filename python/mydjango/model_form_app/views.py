from django.shortcuts import render,HttpResponse
from model_form_app.models import TestTable
from model_form_app.forms import TestTableForm,TestForm

# Create your views here.
def index(request):
	if request.method == 'POST':
		name = request.POST.get('name')
		if name:
			TestTable.objects.create(name=name)
		return HttpResponse(name)
	return render(request,"model_form_app/index.html")

def index2(request):
	if request.method == 'POST':
		form = TestTableForm(request.POST)
		if form.is_valid():
			#TestTable.objects.create(name=name)
			name = form.cleaned_data.get('name')
			t1 = TestTable(name=name)
			t1.save()
		return HttpResponse(name)
	else:	
		form = TestTableForm()
	return render(request,"model_form_app/index2.html",{'form':form})
	
def index3(request):
	if request.method == 'POST':
		forms = TestForm(request.POST)
		if forms.is_valid():
			forms.save()  #与模型类关联的表单，可以直接在校验成功的时候通过save函数存储
			return HttpResponse('OK')	
		#else:
		#校验失败的字段会放到form.errors中
		#	return HttpResponse('ERROR')
	else:
		forms = TestForm()
	return render(request,"model_form_app/index3.html",{'forms':forms})
