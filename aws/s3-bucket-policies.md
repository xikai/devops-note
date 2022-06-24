* https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/bucket-policies.html

# 何时需要使用存储桶策略
* 对于其他 AWS 账户或其他账户中用户的跨账户权限，则必须使用存储桶策略
* 或无法确定帐户信息时

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