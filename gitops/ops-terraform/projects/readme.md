# 1. 配置aws credentials
### AWS profile
```
# vim ~/.aws/config
[prod]
output = json
region = us-west-2
[test]
output = json
region = cn-northwest-1
```
```
# vim ~/.aws/credentials
[prod]
aws_access_key_id = <aws_access_key_id>
aws_secret_access_key = <aws_secret_access_key>
[test]
aws_access_key_id = <aws_access_key_id>
aws_secret_access_key = <aws_secret_access_key>
```
* vim ~/.zshrc ,切换aws测试profile credentials
```
# AWS_PROFILE
alias awstest='export AWS_PROFILE=test'
alias awsprod='export AWS_PROFILE=prod'
```
```
source ~/.zshrc
awstest     #切换test profile
awsprod     #切换prod profile
```

# 2. [terraform cloud存储状态](https://cloud.hashicorp.com/products/terraform)
>在生产环境中，您应该保持状态的安全和加密，以便您的团队成员可以访问它以在基础设施上进行协作。做到这一点的最佳方法是在具有共享状态访问权限的远程环境中运行 Terraform
 - HCP Terraform通过在一致且可靠的环境中（而不是在本地计算机上）管理 Terraform 运行来构建这些功能。它安全地存储状态和秘密数据，并且可以连接到版本控制系统，以便您可以使用类似于应用程序开发的工作流程来开发基础设施。
 - Terraform 可帮助您在基础设施开发流程的每个步骤上进行协作。例如，每次您计划新的变更时，您的团队都可以在应用之前审核并批准该计划。它还在操作期间自动锁定状态，以防止可能损坏状态文件的并发修改。

* [注册terraform cloud帐号](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up#create-an-account)
  - [注册页面](https://app.terraform.io/signup/account) 
  - [创建organization](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up#create-an-organization)

* [编写Terraform cloud配置](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-remote#set-up-hcp-terraform)
```
terraform {
  cloud {
    organization = "vevorops"
    workspaces {
      name = "vevor-terraform-aws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}
```

* [登陆terraform cloud](https://developer.hashicorp.com/terraform/tutorials/cloud/cloud-login)
```
$ terraform login   #Terraform将以明文存储token到 $HOME/.terraform.d/credentials.tfrc.json

1. Creating a user token，保存到一个安全的位置 ，用于对HCP Terraform organization的访问
2. 返回终端，输入以上token
```

# 3. 执行terraform
* 初始化
  - terraform下载provider并安装到.terraform隐藏目录，创建.terraform.lock.hcl锁文件指定所使用的提供程序的确切版本，以便您可以控制何时更新项目使用的提供程序
  - 如果您设置或更改modules或Terraform{}设置，请运行“Terraform init”。再次初始化您的工作目录。
```
$ terraform init
```

* 格式化、验证、检查（非必须）
```
$ terraform fmt       #自动更新当前目录中的配置，以提高可读性和一致性
$ terraform validate  #语法检测
$ terraform plan      #生成执行计划 （重复运行plan可以帮助清除语法错误，并确保您的配置符合预期）
```

* 创建执行(Terraform 默认将有关资源的数据存储在本地状态文件terraform.tfstate中)
```
$ terraform apply
-/+ 销毁/创建资源，而不是就地更新它
~ 就地更新某些属性
```

* 销毁资源
```
$ terraform destroy
```

# 注意事项
```
git config --global core.autocrlf "input" #设置代码格式统一为LF（主要为windows，mac默认格式为LF）
```