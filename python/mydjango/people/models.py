from django.db import models

# Create your models here.
class Account(models.Model):
	balance = models.CharField(max_length=10)
	msgNum = models.CharField(max_length=10)

class Product(models.Model):
	productDate = models.DateField()
	productName = models.CharField(max_length=10)
	productNum = models.IntegerField()

class User(models.Model):
	username = models.CharField(max_length=10)
	password = models.CharField(max_length=10)