# 建立vpn连接
* ipsec vpn / vpc对等连接
```
subnetA(不能访问googleapi) --- 172.31.36.155 --- internel(vpn tunnel) --- 172.16.0.1 --- subnetB(能访问googleapi)
```

# 通过添加路由让subnetA 访问googleapi
* [获取googleapi 公网网段](https://cloud.google.com/vpc/docs/configure-private-google-access#ip-addr-defaults)
* https://support.google.com/a/answer/10026322?hl=zh-Hans
```py
#!/usr/bin/env python3

import json
import netaddr
import urllib.request

goog_url="https://www.gstatic.com/ipranges/goog.json"
cloud_url="https://www.gstatic.com/ipranges/cloud.json"

def read_url(url):
   try:
      s = urllib.request.urlopen(url).read()
      return json.loads(s)
   except urllib.error.HTTPError:
      print("Invalid HTTP response from %s" % url)
      return {}
   except json.decoder.JSONDecodeError:
      print("Could not parse HTTP response from %s" % url)
      return {}

def main():
   goog_json=read_url(goog_url)
   cloud_json=read_url(cloud_url)

   if goog_json and cloud_json:
      print("{} published: {}".format(goog_url,goog_json.get('creationTime')))
      print("{} published: {}".format(cloud_url,cloud_json.get('creationTime')))
      goog_cidrs = netaddr.IPSet()
      for e in goog_json['prefixes']:
         if e.get('ipv4Prefix'):
            goog_cidrs.add(e.get('ipv4Prefix'))
      cloud_cidrs = netaddr.IPSet()
      for e in cloud_json['prefixes']:
         if e.get('ipv4Prefix'):
            cloud_cidrs.add(e.get('ipv4Prefix'))
      print("IP ranges for Google APIs and services default domains:")
      for i in goog_cidrs.difference(cloud_cidrs).iter_cidrs():
         print(i)

if __name__=='__main__':
   main()
```

* 添加路由
```
https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route-table.html
https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/delete-route-table.html
https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route.html
https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/delete-route.html
```
```
aws ec2 create-route --route-table-id rtb-22574640 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-c0a643a9
aws ec2 create-route --route-table-id rtb-g8ff4ea2 --destination-cidr-block 10.0.0.0/16 --vpc-peering-connection-id pcx-1a2b3c4d
```