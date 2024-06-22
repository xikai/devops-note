* https://help.aliyun.com/zh/cli/?spm=a2c4g.11186623.0.0.75b9478doYPTzO
* https://help.aliyun.com/zh/sdk/developer-reference/v2-manage-access-credentials?spm=a2c4g.11186623.0.i1#3ca299f04bw3c

# 安装aliyun-cli
```sh
brew install aliyun-cli
```
# 配置aliyun-cli
>$HOME/.aliyun/config.json
```sh
aliyun configure [--mode <AuthenticateMode>] [--profile <profileName>]
```
* 非交互
```sh
aliyun configure set \
  --profile akProfile \
  --mode AK \
  --region cn-hangzhou \
  --access-key-id AccessKeyId \
  --access-key-secret AccessKeySecret \
  --language zh
```

* aliyun configure
```sh
aliyun configure list
aliyun configure get --profile akProfile
aliyun configure delete --profile akProfile
```
* 命令自动补全
```sh
aliyun auto-completion
aliyun auto-completion --uninstall
```
* profile系统变量
```
# terraform
export ALICLOUD_PROFILE=prod
```
