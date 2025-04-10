#!/bin/bash

echo "==========sh start================="
BUILD_ENV=$1
BUILD_NUMBER=$2
#签名后重命名的文件名
apkSignedName="${BUILD_ENV}-${BUILD_NUMBER}.apk"
echo $apkSignedName

if [[ "${BUILD_ENV}" = "hotel_admin_dev" ]] ;then
    echo "gradle assembleDevRelease"
    gradle assembleDevRelease
    cd ./app/build/outputs/apk/dev/release
    apkUnSign=$(ls | grep *.apk)
fi

if [[ "${BUILD_ENV}" = "hotel_admin_stg" ]] ;then
    echo "gradle assembleStagingRelease"
    gradle assembleStagingRelease
    cd ./app/build/outputs/apk/staging/release
    apkUnSign=$(ls | grep *.apk)
fi

if [[ "${BUILD_ENV}" = "hotel_admin_pre" ]] ;then
    echo "gradle assemblePreRelease"
    gradle assemblePreRelease
    cd ./app/build/outputs/apk/pre/release
    apkUnSign=$(ls | grep *.apk)
fi

if [[ "${BUILD_ENV}" = "hotel_admin_prod" ]] ;then
    echo "gradle assembleProductionRelease"
    gradle assembleProductionRelease
    cd ./app/build/outputs/apk/production/release
    apkUnSign=$(ls | grep *.apk)
fi


 
mv $apkUnSign $WORKSPACE/$apkSignedName
cd $WORKSPACE
if [ -e $apkSignedName ]
then
    echo "打出的包: ${apkSignedName}"
else
    echo "..........apk不存在 ..........."
    exit 1
fi

echo "...........上传apk到蒲公英..........."
commitMsg=$(git log -1 --pretty='format:%an:%B%s')
curl -F "file=@$apkSignedName" -F "updateDescription=${commitMsg}" -F "uKey=34b4f86818daab4ee7e2966c3297db59" -F "_api_key=7c42f10c269a12c5ac964d51605bee39" https://qiniu-storage.pgyer.com/apiv1/app/upload



#echo "...........上传apk..........."
#chmod +x ossutil64
#oss="./ossutil64  -i $accessKeyID -k $accessKeySecret -e $endpoint"
#ossPath="oss://dd01-android-download/hotel_admin/"
#$oss cp $apkSignedName ${ossPath}
#ossUrlPath=$($oss sign ${ossPath}${apkSignedName} --timeout=2592000 --endpoint=oss-cn-shenzhen.aliyuncs.com) #链接有效期，单位秒，（30天）
#apkUrl=(${ossUrlPath// / })
#echo $apkUrl
#
#echo '...........发送消息通知测试人员 ...........'
#echo ${TRAVIS_COMMIT_MESSAGE}
#if [ $TRAVIS_PULL_REQUEST != 'false' ]
#then
#msg=$(git log -1 --pretty='format:%an:%B')
#else
#msg=$(git log -1 --pretty='format:%an:%b')
#fi
#commitMsg=`echo ${msg} | tr ' ' '-'`
#
#curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=4a15d8bd-c5c5-4b84-9653-e27fdab381f8' \
#      -H 'Content-Type: application/json' \
#      -d '{
#  "msgtype": "markdown",
#  "markdown": {
#    "content": "Android版本名称：<font color=\"warning\">'${TRAVIS_BUILD_NUMBER}-${BUILD_ENV}-${TRAVIS_BRANCH}' </font>
#    \n> 提交信息:<font color=\"comment\">'${commitMsg}'</font>
#    \n> 下载地址：'${apkUrl}'"
#  }
#}'
#