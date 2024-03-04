# NPM（nodejs package manager）
1. npm是Node.js的包管理工具。为啥我们需要一个包管理工具呢？因为我们在Node.js上开发时，会用到很多别人写的JavaScript代码。如果我们要使用别人写的某个包，每次都根据名称搜索一下官方网站，下载代码，解压，再使用，非常繁琐。于是一个集中管理的工具应运而生：大家都把自己开发的模块打包后放到npm官网上，如果要使用，直接通过npm安装就可以直接用，不用管代码存在哪，应该从哪下载.
2. 更重要的是，如果我们要使用模块A，而模块A又依赖于模块B，模块B又依赖于模块X和模块Y，npm可以根据依赖关系，把所有依赖的包都下载下来并管理起来。否则，靠我们自己手动管理，肯定既麻烦又容易出错。

* 官方仓库
```
# 注册帐号
https://www.npmjs.com/

https://registry.npmjs.org
```

* npm github私有仓库
```
https://github.com/features/packages
```

# 下载并安装 node 和 npm
>安装 Node.js 时，会自动安装 npm(我们强烈建议使用 Node 版本管理器来安装 Node.js 和 npm。不建议使用 Node 安装程序，因为 Node 安装过程会将 npm 安装在具有本地权限的目录中，并且在全局运行 npm 包时可能会导致权限错误)。Node 版本管理器允许你在系统上安装和切换多个版本的 Node.js 和 npm，以便你可以在多个版本的 npm 上测试你的应用，以确保它们适用于不同版本的用户
* [使用 Node 版本管理器nvm安装 Node.js 和 npm](https://github.com/nvm-sh/nvm)
    ```
    # git克隆nvm仓库到~/.nvm 
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # 验证nvm安装完成，运行安装脚本后，如果出现“nvm: command not found” . ~/.nvm/nvm.sh
    command -v nvm

    #列出可用版本
    nvm ls-remote --lts 
    nvm install --lts   # 安装最新版本nodejs
    nvm install 14.17.0  # 安装指定版本nodejs

    # Now using node v16.9.1 (npm v7.21.1)
    nvm use 16  
    # Now using node v14.17.0 (npm v6.14.15)
    nvm use 14 

    # 将 12.7.0 设置为 Node 的默认版本 
    nvm alias default v12.7.0 

    # 查看已经安装的 Node 版本
    nvm ls [<version>]

    #查看当前node版本
    nvm current

    #获取PATH
    nvm which 14.17.0 

    # Manual Uninstall
    rm -rf "$NVM_DIR"  
    ```
* [使用 Node 安装程序安装 Node.js 和 npm](https://nodejs.org/en/download)

# npm命令
* npm install - 下载依赖包（优先查找cache）安装到本地当前 node_modules 文件夹，是项目特定的只存储与当前项目相关的包，确保项目能够正常运行
  1. 默认情况下 将安装 package.json 中列为依赖的所有模块
  2. 如果包有一个包锁，或者一个 npm 收缩封装文件，或者一个 Yarn 锁文件，依赖的安装将由它驱动，遵循以下优先顺序：npm-shrinkwrap.json > package-lock.json > yarn.lock
  ```
  npm install -g/--global  #Unix系统上 npm将依赖包全局安装转到{prefix}/lib/node_modules目录(prefix默认是安装node的位置)
  npm install --production #或者当 NODE_ENV 环境变量设置为 production 时，npm 将不会安装 devDependencies 中列出的模块
  ```

* npm config - 管理 npm 配置文件
  1. npm获取其配置值，按优先级排序: 命令行标志 > 环境变量 > npmrc文件 > 默认配置
  ```
  每个项目的配置文件 (/path/to/my/project/.npmrc)
  每个用户的配置文件（默认为 $HOME/.npmrc；可通过 CLI 选项 --userconfig 或环境变量 $NPM_CONFIG_USERCONFIG 配置）
  全局配置文件（默认为 $PREFIX/etc/npmrc；可通过 CLI 选项 --globalconfig 或环境变量 $NPM_CONFIG_GLOBALCONFIG 配置）
  npm 的内置配置文件（/path/to/npm/npmrc）
  ```
  ```
  npm config ls -l 显示所有设置，-l 也可以显示默认值
  npm config set key=value
  ```

* npm cache - 用于缓存已下载的包，包缓存失效前可以从缓存中获取而不是重新下载
>此命令对工作区无感知 默认路径：~/.npm
```
# 将指定的包添加到本地缓存
npm cache add <package-spec>

# 删除缓存文件夹中的所有数据
npm cache clean [<key>]
```


# 参考文档
* https://docs.npmjs.com/
* https://npm.nodejs.cn/
