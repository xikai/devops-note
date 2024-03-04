# KMS密钥类型
* 对称加密 
  - 表示单个 256 位 AES-GCM 加密密钥，但在中国区域，它表示 128 位 SM4 加密密钥。对称密钥材料绝不会让 AWS KMS 处于未加密状态。要使用对称加密 KMS 密钥，必须调用 AWS KMS
  - 加密和解密采用的是相同的密钥,除非任务明确要求使用非对称加密，否则使用对称加密 KMS 密钥。
* 非对称密钥（公有密钥和私有密钥对） 
  - 公有密钥可以交给任何人，即使他们不可靠，但私有密钥必须保密。
  - 在非对称 KMS 密钥中，私有密钥是在 AWS KMS 中创建的，它永远不会让 AWS KMS 处于未加密状态。要使用私有密钥，必须调用 AWS KMS。您可以通过调用 AWS KMS API 操作在 AWS KMS 内使用公有密钥。或者，可以下载公有密钥并在 AWS KMS 外部使用该密钥。
  — 无法调用 AWS KMS 的用户 如果需要在 AWS 外部进行加密，那么非对称 KMS 密钥是个不错的选择。
* HMAC（散列消息认证码）密钥
  - 表示长度不同的对称密钥，用于生成和验证散列消息认证码。HMAC KMS 密钥中的密钥材料绝不会让 AWS KMS 处于未加密状态。要使用 HMAC KMS 密钥，您必须调用 AWS KMS。

### [数据密钥](https://docs.aws.amazon.com/zh_cn/kms/latest/developerguide/concepts.html)
* 当 AWS KMS 生成数据密钥时，它会返回供立即使用的明文数据密钥（可选）和可以随数据安全存储的数据密钥的加密副本。准备好解密数据时，首先要求 AWS KMS 解密已加密的数据密钥。
* AWS KMS 会生成、加密和解密数据密钥。但是，AWS KMS 不会存储、管理或跟踪您的数据密钥，也不会使用数据密钥执行加密操作。您必须在 AWS KMS 之外使用和管理数据密钥

### 数据密钥对
* 使用数据密钥对加密时，用该密钥对的公有密钥加密数据，然后用同一密钥对的私有密钥解密数据。通常，当多方需要加密数据，而只有持有私有密钥的一方才能解密该数据时，您可以使用数据密钥对

### 信封加密
* 在您加密数据后，数据将受到保护，但您必须保护加密密钥 例如：数据密钥，使用数据密钥对明文数据进行加密，然后使用KMS密钥对数据密钥进行加密
```
kms密钥（客户托管密钥/root根密钥）-encrypts-> data key -encrypts-> data
```
### 密钥材料
  - 即加密操作中 加密算法使用的一串字符,每个 KMS 密钥的元数据中都包含对其密钥材料的引用。
  - 密钥轮换只会更改密钥材料

# 创建 KMS 密钥
>KMS 密钥属于创建它们的 AWS 账户。创建 KMS 密钥的 IAM 用户不会被视为密钥的拥有者，且他们不会自动获得使用或管理自己所创建 KMS 密钥的权限。与任何其他主体一样，密钥创建者需要通过密钥策略、IAM policy 或授权获得权限。但是，拥有 kms:CreateKey 权限的主体可以设置初始密钥策略，并授予自己使用或管理密钥的权限。
```
# 创建一个具有 AWS KMS 生成的密钥材料的对称加密 KMS 密钥
aws kms create-key  #此命令使用所有默认值
```

# AWS CLI加密解密
* https://awscli.amazonaws.com/v2/documentation/api/latest/reference/kms/encrypt.html
* https://awscli.amazonaws.com/v2/documentation/api/latest/reference/kms/decrypt.html

* base64编码
```
# 为避免数据以明文形式显示在CloudTrail日志和其他输出中，kms不能直接加密明文数据；需先通过base64编码
# base64编码
base64 <<< "123456"   //输出 MTIzNDU2Cg==
# base64解码
base64 -d <<< "MTIzNDU2Cg=="
```
* 将base64编码后的二进制密文保存到文件中，以便于kms解密
```
aws kms encrypt \
    --key-id alias/demo-test \
    --plaintext MTIzNDU2Cg== \
    --output text \
    --query CiphertextBlob | base64 \       #--query CiphertextBlob从命令的输出中提取加密数据，称为密文;执行成功的加密命令返回的密文是base64编码的文本。您必须先解码此文本，然后才能使用AWS CLI对其解密。
    --decode >ExampleEncryptedFile  
```
```
aws kms decrypt \
    --ciphertext-blob fileb://ExampleEncryptedFile \
    --key-id alias/demo-test \
    --output text \
    --query Plaintext | base64 \
    --decode
```
* 直接加解密密文文本
```
# kms加密base64编码后的数据，返回加密密文
aws kms encrypt \
    --key-id alias/demo-test \
    --plaintext MTIzNDU2Cg== \
    --output text \
    --query CiphertextBlob

//输出：AQICAHgBvdjKW8KAwu1A56P8KHgwKuxE9xcUtTClQWobG+S18wEz8Hu4g0pmhFW44S6inP4WAAAAZTBjBgkqhkiG9w0BBwagVjBUAgEAME8GCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMpDu8camxanjDBDyqAgEQgCJ38UHYXuh03XAMyu6kz8EAxD5p6gjJcaRdjIDocGvqJrlG
```
```
# kms解密密文，并base64解码
aws kms decrypt \
    --ciphertext-blob AQICAHgBvdjKW8KAwu1A56P8KHgwKuxE9xcUtTClQWobG+S18wEz8Hu4g0pmhFW44S6inP4WAAAAZTBjBgkqhkiG9w0BBwagVjBUAgEAME8GCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMpDu8camxanjDBDyqAgEQgCJ38UHYXuh03XAMyu6kz8EAxD5p6gjJcaRdjIDocGvqJrlG \
    --key-id alias/demo-test \
    --output text \
    --query Plaintext | base64 \
    --decode

输出：123456
```

### 相关文档
* https://docs.aws.amazon.com/zh_cn/kms/latest/developerguide/overview.html
* https://awscli.amazonaws.com/v2/documentation/api/latest/reference/kms/index.html