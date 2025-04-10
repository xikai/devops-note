<?php

namespace think;

$version = 'default';
//$version = 'version_1.6';
if (isset($_SERVER['HTTP_FMS_VERSION']) && $_SERVER['HTTP_FMS_VERSION']) {
    $version = 'version_' . $_SERVER['HTTP_FMS_VERSION'];
}

define('APP_PATH', __DIR__ . '/../application/' . $version . '/');
define('ROOT_PATH', __DIR__ . '/../');
define('ENV_PREFIX', ''); // 环境变量的配置前缀

// ThinkPHP 引导文件
// 1. 加载基础文件
require __DIR__ . '/../thinkphp/base.php';


try {
    // 2. 执行应用
    App::run()->send();
} catch (\Exception $ex) {

    $msg  = '--exception:' . $ex->getLine() . '行,' . $ex->getFile()
            . ', ' . $ex->getMessage();
    $code = (0 == $ex->getCode()) ? 400 : $ex->getCode();
    // trace($msg, 'error');
    header("Content-type:application/json;charset=utf-8");
    if ((Env::get('ENV')) == 'dev') {
        exit('{"code":' . $code . ',"msg":"Error-err' . $msg . '"}');
    } else {
        exit('{"code":' . $code . ',"msg":"' . $ex->getMessage() . '"}');
    }
} catch (\Error $ex) {
    $msg = 'Error-exception:' . $ex->getLine() . '行,' . $ex->getFile()
           . ', ' . $ex->getMessage();
    // trace($msg, 'error');
    header("Content-type:application/json;charset=utf-8");
    if ((Env::get('ENV')) == 'dev') {
        exit('{"code":500,"msg":"Error-err-' . $msg . '"}');
    } else {
        exit('{"code":500,"msg":"Error-err' . $ex->getMessage() . '"}');
    }
}
