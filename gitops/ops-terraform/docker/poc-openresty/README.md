# POC-openresty

## 说明

此`openresty`项目为结合了独立站`data-gateway-lua`和总部中间件等一些运营域名结合而成
启动方式为运行`start.sh`

## 脚本解释

`/data/openresty/conf.d`: 为总部放置中间件等域名使用的conf
`/data/openresty/www`: 为总部等域名放置静态资源使用
`/data/openresty/poc-data-gateway-lua`:  为独立站`data-gateway-lua`应用放置项目代码文件使用，该`git`地址`git@codeup.aliyun.com:newvevor/share-web/poc-data-gateway-lua.git`，后续`jenkins`更新也是更新这个目录
`/data/openresty/logs`: 此目录为独立站`data-gateway-lua`的`nginx`运行日志