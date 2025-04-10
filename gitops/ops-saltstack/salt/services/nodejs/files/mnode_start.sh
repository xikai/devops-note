#!/bin/sh
website=$1

source /etc/profile
cd /data/www/mnode
/usr/local/node/bin/npm run build
/usr/local/node/bin/npm i
/usr/local/node/bin/pm2 delete m-${website}
/usr/local/node/bin/pm2 start ./start/${website}.prod.config.js
