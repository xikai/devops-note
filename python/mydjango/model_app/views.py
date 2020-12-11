from django.shortcuts import render,HttpResponse
from model_app.models import *

def crud_create(request):
	#p = Teacher(name='二哈',age=10)
    #p.name = '三哈'
    #p.save()
    Teacher.objects.create(name='create的数据',age=10)
    return HttpResponse('OK')

def crud_get(request):
	try:
		t1 = Teacher.objects.get(name="不存在的数据")    #get()只能查唯一数据
	except Teacher.MultipleObjectsReturned:
		return HttpResponse('Error:查询结果太多了！')
	except Teacher.DoesNotExist:
		return HttpResponse('Error:不存在的数据！')

def crud_update(request):
    t1 = Teacher.objects.all().first()
    print(t1)
    t1.name = 'update的数据'
    t1.save()
    return HttpResponse('OK')

def crud_all(request):
    rt = Teacher.objects.all()[:5]
    print(rt)
    print(dir(rt))
    print(type(rt))
    return HttpResponse('OK')

def crud_filter(request):
    rt = Teacher.objects.filter(name__endswith='数据')   #field__rule：字段名双下划线加规则属性
    print(rt)
    #[<Teacher: update的数据>, <Teacher: create的数据>, <Teacher: create的数据>, <Teacher: create的数据>]
    data = "<br>".join([var.name for var in rt])
    return HttpResponse(data)

def crud_filter2(request):
    rt = Company.objects.filter(partner__name='李四')  #__name跨关联关系查询(联表查询)
    print(rt)
    #[<Company: 皮包公司>, <Company: 炸鸡公司>]
    data = "<br>".join([var.name for var in rt])
    return HttpResponse(data)

def crud_filter3(request):
    rt = KidsClass.objects.filter(teacher__name='老李')
    print(rt)
    #data = rt.teacher
    return HttpResponse('Ok')