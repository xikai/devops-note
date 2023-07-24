# [describe-instances](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-instances.html)
* 通过tag获取tag key等于Name的ec2实例
```sh
aws ec2 describe-instances \
    --filters Name=tag-key,Values=Name \
    --query 'Reservations[].Instances[].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output table
```
```sh
aws ec2 describe-instances \
    --filters Name=tag-key,Values=Name \
    --query 'Reservations[].Instances[].{Instance:InstanceId,AZ:Placement.AvailabilityZone,PrivateIpAddress:PrivateIpAddress,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output text |grep zookeeper-new
```

* 通过tag获取ec2实例,tag: Owner=TeamA
```sh
aws ec2 describe-instances \
    --filters Name=tag:Owner,Values=TeamA \
    --query 'Reservations[].Instances[].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output table
```