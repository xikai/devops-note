#!/usr/bin/python
#coding=utf-8
import commands

stat, proStr = commands.getstatusoutput('netstat -tnlp')
tmpList = proStr.split("\n")
del tmpList[0:2]
newList = []
for i in tmpList:
	val = i.split()
	del val[0:3]
	del val[1:3]
	valTmp = val[0].split(":")
	val[0] = valTmp[1]
	valTmp = val[1].split("/")
	val[1] = valTmp[-1]
	if val[0] != "" and val not in newList:
		newList.append(val)

json_data = "{\n" + "\t" + '"data":[' + "\n"
for net in newList:
	if net != newList[-1]:
		json_data = json_data + "\t\t" + "{" + "\n" + "\t\t" + '"{#PPORT}":"' + str(net[0]) + "\",\n" + "\t\t" + '"{#PNAME}":"' + str(net[1]) + "\"},\n"
	else:
		json_data = json_data + "\t\t" + "{" + "\n" + "\t\t" + '"{#PPORT}":"' + str(net[0]) + "\",\n" + "\t\t" + '"{#PNAME}":"' + str(net[1]) + "\"}]" + "\n" +"}"

print json_data
