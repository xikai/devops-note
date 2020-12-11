#encoding:utf-8
# ['abc',[1,['a','b'],3],'def'] 把每一个字符访问出来
l = ['abc',[1,['a','b'],3],'def']

for v in l:
	for v1 in v:
		if type(v1) == list:
			for v2 in v1:
				print(v2)
		else:
			print(v1)