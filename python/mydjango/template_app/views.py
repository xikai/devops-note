from django.shortcuts import render

# Create your views here.
def test(request):
	myint = 123
	myint2 = 100
	mystr = 'this is lily ya'
	mystr2 = 'aaa**'
	mylist = ['a','b','c','d','e']
	mydict = {1:'a',2:'b'}
	msg = '''
		我就想要换个行
		行不行
	'''

	flag = "<h1>aaaaa</h1>"

	cities = [
	    {'name': 'Mumbai', 'population': '19,000,000', 'country': 'India'},   
	    {'name': 'New York', 'population': '20,000,000', 'country': 'USA'},
	    {'name': 'Calcutta', 'population': '15,000,000', 'country': 'India'},
	    {'name': 'Chicago', 'population': '7,000,000', 'country': 'USA'},
	    {'name': 'Tokyo', 'population': '33,000,000', 'country': 'Japan'},
	]

	content = {
		'myint':myint,
		'myint2':myint2,
		'mystr':mystr,
		'mystr2':mystr2,
		'mylist':mylist,
		'mydict':mydict,
		'cities':cities,
		'msg':msg,
		'flag':flag
	}
	return render(request,'template_app/index.html',content)