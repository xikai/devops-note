from django.db import models

class Tabletest(models.Model):
	boolean = models.BooleanField()
	charfield = models.CharField(max_length=10)
	datefield = models.DateField(auto_now_add=True)
	datetime = models.DateTimeField(auto_now_add=True)
	integer = models.IntegerField()
	decimal = models.DecimalField(max_digits=5,decimal_places=2)
	floatnum = models.FloatField(verbose_name="浮点数")
	email = models.EmailField(db_index=True)
	url = models.URLField()
	slug = models.SlugField()
	longchar = models.TextField()
	ip = models.GenericIPAddressField()
	class Meta:
		ordering = ['datetime']
		unique_together = (('url','email'),)
		#verbose_name = '测试表' #单数
		#verbose_name_plural = '测试表' #单数
		#db_table = 'Test Table' #创建表时的表名
		#app_lable = '' #指明当前模型类属于哪个APP
	def __str__(self):
		return str(self.datetime)

class Teacher(models.Model):
	name = models.CharField(max_length=10)
	age = models.IntegerField()
	def __str__(self):
		return self.name

class Professor(models.Model):
	teacher = models.OneToOneField(Teacher,primary_key=True)
	big_project = models.CharField(max_length=10)
	def __str__(self):
		return self.teacher.name

class HeadMaster(models.Model):
	name = models.CharField(max_length=10)
	def __str__(self):
		return self.name

class KidsClass(models.Model):
	teacher = models.ForeignKey(HeadMaster)   #ForeignKey 一对多
	class_name = models.CharField(max_length=10)
	def __str__(self):
		return self.class_name

class Partner(models.Model):
	name =  models.CharField(max_length=10)
	def __str__(self):
		return self.name

class Company(models.Model):
	name = models.CharField(max_length=10)
	partner = models.ManyToManyField(Partner)
	def __str__(self):
		return self.name
