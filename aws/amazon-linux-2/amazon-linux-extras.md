* https://docs.aws.amazon.com/zh_cn/linux/al2/ug/what-is-amazon-linux.html
* 使用 AL2, Extras Library 在实例上安装应用程序和软件更新

* 列出可用主题
```
amazon-linux-extras list
```

* 启用主题并安装其包的最新版本
```
amazon-linux-extras install topic
```
* 要启用主题并安装其包的特定版本
```
amazon-linux-extras install topic=version
```

* 删除从主题中安装的包
```
yum remove $(yum list installed | grep amzn2extra-topic | awk '{ print $1 }')
```

* 禁用主题并使 yum 包管理器无法访问包
>此命令适用于高级用户。此命令使用不当可能会导致包兼容性冲突。
```
amazon-linux-extras disable topic
```

# AL2023 doesn't include amazon-linux-extras