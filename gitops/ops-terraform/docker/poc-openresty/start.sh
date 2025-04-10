#!/bin/bash
CURRENT_DIR=$(dirname $0)

mkdir -p /data/openresty/{logs,poc-data-gateway-lua,conf.d,www}
chmod 777 -R  /data/openresty

# more comments via README.md
cd /data/openresty
wget https://vevor-packages.oss-cn-shanghai.aliyuncs.com/front/openresty_conf.tar.gz 
wget https://vevor-packages.oss-cn-shanghai.aliyuncs.com/front/poc-data-gateway-lua.tar.gz 
wget https://vevor-packages.oss-cn-shanghai.aliyuncs.com/front/www-ssr.tar.gz 
wget https://vevor-packages.oss-cn-shanghai.aliyuncs.com/jenkins/tools.tar.gz -P /usr/local/

tar xf /usr/local/tools.tar.gz -C /usr/local/
tar xf openresty_conf.tar.gz
tar xf poc-data-gateway-lua.tar.gz
tar xf www-ssr.tar.gz

/bin/rm -f openresty_conf.tar.gz  
/bin/rm -f poc-data-gateway-lua.tar.gz
/bin/rm -f www-ssr.tar.gz
/bin/rm -f /usr/local/tools.tar.gz

echo '
export NODEJS_HOME=/usr/local/node
export NODE_HOME=/usr/local/node
export PATH=$PATH:$NODEJS_HOME/bin:$NODE_HOME/bin' >>/etc/profile

source /etc/profile
npm install -g pm2 --registry=https://registry.npmmirror.com
npm install -g cross-env --registry=https://registry.npmmirror.com
num=`pm2 list|grep vevor-admin|wc -l`
cd /data/openresty/www/vevor-admin-ssr
if [ $num == 1 ];then
    bash -x  start.sh
else
    PM2_HOME='/root/.pm2' cross-env CONFIG_ENV=hzgm pm2 start dist/main.js --name vevor-admin
    PM2_HOME='/root/.pm2' pm2 list
    bash -x start.sh
fi

docker run -d --name poc-openresty \
  --restart=always \
  --net=host \
  -v /data/openresty/conf.d:/etc/nginx/conf.d \
  -v /data/openresty/www:/srv \
  -v /data/openresty/poc-data-gateway-lua:/usr/local/openresty/lualib/data-gateway-lua \
  -v /data/openresty/logs:/fdata/logs/data-openresty \
  $1/poc-openresty:1.0