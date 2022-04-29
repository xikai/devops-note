* https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/bucket-policies.html
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