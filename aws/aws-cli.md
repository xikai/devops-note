* https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/cli-chap-welcome.html

# 获取当前aksk的用户身份信息
```
aws sts get-caller-identity
```

# [describe-instance-types查询aws实例信息](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-instance-types.html)
* https://aws.amazon.com/cn/ec2/instance-types/
* https://aws.amazon.com/cn/ec2/instance-explorer/
* 查询实例规格对应的CPU内存大小
```sh
aws ec2 describe-instance-types --instance-type m6g.xlarge \
    --query 'InstanceTypes[].{InstanceType:InstanceType,vCPU:VCpuInfo.DefaultVCpus,"Memory (MiB)":MemoryInfo.SizeInMiB,Network:NetworkInfo.NetworkPerformance}' \
    --output table
```
* 查询m6系列的实例信息，并按内存大小排序
```sh
aws ec2 describe-instance-types \
    --filters 'Name=instance-type,Values=m6*' \
    --query 'sort_by(InstanceTypes,&MemoryInfo.SizeInMiB)[].{InstanceType:InstanceType,vCPU:VCpuInfo.DefaultVCpus,"Memory (MiB)":MemoryInfo.SizeInMiB,Network:NetworkInfo.NetworkPerformance}' \
    --output table
```
* 查询指定CPU内存大小对应的实例规格
```sh
aws ec2 describe-instance-types \
    --filters 'Name=vcpu-info.default-vcpus,Values=4' 'Name=memory-info.size-in-mib,Values=16384' \
    --query 'InstanceTypes[].{InstanceType:InstanceType,vCPU:VCpuInfo.DefaultVCpus,"Memory (MiB)":MemoryInfo.SizeInMiB,Network:NetworkInfo.NetworkPerformance}' \
    --output table
```

# [describe-instances查询现有实例](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-instances.html)
* tag-key: 查找tag具有特定key的所有资源，而不管tag值如何
```sh
# --filters过滤标签key包含Name的所有资源，--query列出要展示的字段
aws ec2 describe-instances \
    --filters Name=tag-key,Values=Name \
    --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`]|[0].Value,Instance:InstanceId,InstanceType:InstanceType,PublicIpAddress:PublicIpAddress,PrivateIpAddress:PrivateIpAddress,AZ:Placement.AvailabilityZone}' \
    --output table
```
* 过滤实例类型为t3.2xlarge的实例
```sh
aws ec2 describe-instances \
    --filters Name=instance-type,Values=t3.2xlarge \
    --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`]|[0].Value,Instance:InstanceId,InstanceType:InstanceType,PublicIpAddress:PublicIpAddress,PrivateIpAddress:PrivateIpAddress,AZ:Placement.AvailabilityZone}' \
    --output table
```
* 过滤指定私有IP的实例
```sh
aws ec2 describe-instances \
    --filters Name=private-ip-address,Values=172.28.40.246 \
    --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`]|[0].Value,Instance:InstanceId,InstanceType:InstanceType,PublicIpAddress:PublicIpAddress,PrivateIpAddress:PrivateIpAddress,AZ:Placement.AvailabilityZone}' \
    --output table
```
* 过滤Name包含jenkins的实例
```sh
aws ec2 describe-instances \
--query 'Reservations[].Instances[?Tags[?Key==`Name` && contains(Value, `jenkins`)]].{Name:Tags[?Key==`Name`]|[0].Value,Instance:InstanceId,InstanceType:InstanceType,PublicIpAddress:PublicIpAddress,PrivateIpAddress:PrivateIpAddress,AZ:Placement.AvailabilityZone}' \
--output text
```