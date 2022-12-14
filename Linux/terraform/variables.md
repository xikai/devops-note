# 输入变量
>Terraform 加载当前目录中以 结尾的所有文件.tf，因此您可以随意命名配置文件。
* vim variables.tf
```
variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}
```
* vim main.tf
```
resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  tags = {
    Name = var.instance_name    #引用上面的variable "instance_name"
  }
}
```

# 输出变量
* vim outputs.tf
```
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
```
* 查询输出变量
```
terraform output
```