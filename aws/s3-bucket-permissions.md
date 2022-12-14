* https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/s3-access-control.html

* 默认情况下，所有 Amazon S3 资源都是私有的，包括存储桶、对象和相关子资源（例如，lifecycle 配置和 website 配置）。只有资源拥有者和创建资源的 AWS 账户可以访问该资源。资源拥有者可以选择通过编写访问策略授予他人访问权限。
* 预设情况下，当另一个 AWS 账户 将对象上载到您的 S3 存储桶，该账户（对象编写者）拥有该对象，拥有对象的访问权限，并可以授予其他用户通过 ACL 访问该数据元的权限。您可以使用对象所有权来更改此原定设置行为，以便禁用 ACL，并且作为存储桶拥有者，您可以自动拥有存储桶中的每个对象。
* 当 Amazon S3 收到请求 (例如，存储桶或对象操作) 时，它首先验证请求者是否拥有必要的权限。Amazon S3 对所有相关访问策略、用户策略和基于资源的策略 (存储桶策略、存储桶 ACL、对象 ACL) 进行评估，以决定是否对该请求进行授权。为了确定请求者是否拥有执行特定操作的权限，Amazon S3 会在收到请求时按顺序执行以下操作
  1. 在运行时将所有相关访问策略 (用户策略、存储桶策略、ACL) 转换为一组策略以进行评估。
  2. 通过以下步骤评估生成的策略集。在每个步骤中，Amazon S3 都会基于特定上下文机构来评估上下文中的策略子集
      1.  用户上下文 - IAM策略
      2. 存储桶上下文 - 如果请求是针对存储桶操作发出的，则请求者必须拥有来自存储桶拥有者的权限。如果请求是针对对象发出的，则 Amazon S3 会评估由存储桶拥有者拥有的所有策略，以检查存储桶拥有者是否未显式拒绝对该对象的访问。如果设置了显式拒绝，则 Amazon S3 不对请求授权。
      3. 对象上下文 – 如果请求是针对对象发出的，则 Amazon S3 对由对象拥有者拥有的策略子集进行评估


# 阻止公有访问
* 默认情况下，新存储桶、访问点和对象不允许公有访问。但是，用户可以修改存储桶策略、访问点策略或对象权限以允许公有访问。S3 阻止公有访问设置会覆盖这些策略和权限，以便于您可以限制这些资源的公有访问。
```
* 公有 – 所有人都拥有以下一项或多项访问权限：列出对象、写入对象、读取和写入权限。
* 对象可以是公有的 – 存储桶不是公有的，但具有适当权限的任何人都可以授予对象公有访问权限。
* 存储桶和对象不是公有的 – 存储桶和对象没有任何公有访问权限。
* 仅限此账户的授权用户 – 由于存在授予公有访问权限的策略，因此访问权限仅限于此账户中的 IAM 用户和角色以及 Amazon 服务委托人。
```
* [Amazon S3 Block Public Access提供了四种设置，如果接入点、桶或帐户的阻止公共访问设置不同，那么Amazon S3将应用设置的最严格组合](https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/access-control-block-public-access.html#access-control-block-public-access-options)


# [存储桶策略](https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/bucket-policies.html)
* 对于其他 AWS 账户或其他账户中用户的跨账户权限，则必须使用存储桶策略
* 或无法确定帐户信息时
* 存储桶策略是基于资源的策略,在 Amazon S3 中授予权限时，您要决定谁获得权限，获得对哪些 Amazon S3 资源的权限，以及您允许对这些资源执行的具体操作
> Amazon S3 > 存储桶 > s3_bucket > 编辑存储桶策略
1, [向匿名用户授予只读权限](https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-use-case-2)
* 必须先禁用“阻止公有访问”
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::DOC-EXAMPLE-BUCKET/*"
            ]
        }
    ]
}
```
* 对IAM用户授权（一般用于跨AWS帐号授权）
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllPrivilegesForSpecificUser",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789012:user/test"
                /*"AWS": [
                    "arn:aws:iam::123456789012:user/test"
                    "arn:aws:iam::123456789012:user/test2"
                ]*/
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::DOC-EXAMPLE-BUCKET",
                "arn:aws:s3:::DOC-EXAMPLE-BUCKET/*"
            ]
        }
    ]
}
```

# [对象所有权](https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/about-object-ownership.html)
* 控制从其他 AWS 账户写入到此存储桶的对象所有权以及访问控制列表 (ACL) 的使用。对象所有权决定谁可以指定对象的访问权限。

### [访问控制列表(ACL)](https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/acls.html)
> Amazon S3 中的大多数现代使用案例不再需要使用 ACL，我们建议您禁用 ACL，除非在需要单独控制每个对象的访问,在对象级别管理权限。使用对象所有权，您可以禁用 ACL 并依赖策略进行访问控制。


# [跨源资源共享(CORS)](https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/cors.html)
>配置s3允许跨域请求