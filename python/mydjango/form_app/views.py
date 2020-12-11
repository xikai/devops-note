from django.shortcuts import render
from form_app.forms import PersonForm

def forms(request):
	if request.method == 'GET':
		form = PersonForm()
		#print(form)
		return render(request,"form_app/forms.html",{'form':form})
	else:
		form = PersonForm(request.POST)
		#print(form)
		if form.is_valid():
			print(form.cleaned_data)
		return render(request,"form_app/forms.html",{'form':form})
