yum install libXext libXrender fontconfig
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

. ~/.nvm/nvm.sh

# 安装最新版本nodejs
nvm install --lts

# 测试nodejs是否安装成功
node -e "console.log('Running Node.js ' + process.version)"