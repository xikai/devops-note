https://docs.gitlab.com/runner/

* gitlab 提供持续集成服务。如果将.gitlab-ci.yml 文件添加到存储库的根目录中, 并将 gitlab 项目配置为使用Runner, 则每次commit或push都会触发 ci pipeline。
* gitlab8.0+ CI被完全集成到gitlab中，默认所有项目开启CI
* 一个CI工作所需的步骤包括：
  - 添加.gitlab-cie.yml文件到repository存储库的根目录
  - 配置一个Runner服务器,运行.gitlab-cie.yml定义的CI任务

### 在项目根目录创建.gitlab-ci.yml文件,push到远程仓库
* https://docs.gitlab.com/ee/ci/yaml/README.html
* https://segmentfault.com/a/1190000011881435
* https://segmentfault.com/a/1190000011890710
* stages定义的元素的顺序决定了job执行的顺序,如果其中某一步场景某一个job失败了, 那么提交将会被标记为失败，并且之后的stage和job将不会执行.
* job指定的stage名相同，该多个job将并行执行
* 如果.gitlab-ci.yml中没有定义stages，那么job's stages 会默认定义为 build，test 和 deploy
* 如果一个job没有指定stage阶段，该job将会默认为test场景阶段
```
#image: php:7.1

#services:
#  - mysql:5.6

#variables:
#  # Configure mysql environment variables (https://hub.docker.com/_/mysql/)
#  MYSQL_DATABASE: el_duderino
#  MYSQL_ROOT_PASSWORD: mysql_strong_password

#cache:
#  paths:
#    - vendor/

before_script:
  - echo 'before all job to run'

stages:
  - test
  - build
  - deploy

test:
  stage: test
  image: php:7.2
  #services:
  #  - mysql:5.7
  script:
    - vendor/bin/phpunit --bootstrap src/Email.php tests/EmailTest
  only:
    - master
    - development

deploy_test:
  stage: deploy
  before_script: #会覆盖全局的before_script
    - apk update
    - apk add rsync openssh-client
  script:
    - echo "Deploy to test server"
    - rsync -avzp --delete --partial -e "ssh -p 28 -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no" ./ ubuntu@172.18.232.19:/srv/phpcicd
  environment:
    name: test
    url: https://test.example.com
  only:
  - development

deploy_staging:
  stage: deploy
  before_script: #会覆盖全局的before_script
    - apk update
    - apk add rsync openssh-client
  script:
    - echo "Deploy to staging server"
  environment:
    name: staging
    url: https://staging.example.com
  when: manual
  only:
  - master
```

* 现在如果您转到“pipelines”页面，您将看到pipelines处于pending状态,我们需要为这个jobs分配runner


### Runner服务器
* Runner服务器通过api和gitlab服务器通信
* 不建议Runer和gitlab安装在相同主机，建议每个Runner使用单独的机器运行
* 一个Runner可以被分配给gitlab中一个特定的项目或多个项目或所有项目（Shared Runners）,对CI有很高要求的项目可以使用shared runner，一个specific runner可以分配到多个项目。

### 安装Runner服务器
```
docker run -d --name gitlab-runner --restart always \
   -v /srv/gitlab-runner/config:/etc/gitlab-runner \
   -v /var/run/docker.sock:/var/run/docker.sock \
   gitlab/gitlab-runner:latest
```

### 为gitlab注册Runner服务器
* 获取project registration token
```
# shared runner token 
admin/runners页面(只有系统管理员能够创建Shared Runner)  hxz2HxzY3D6MDLgBzHs5

# specific runner token
project/settings/ci&cd页面    6fhvwZPB-FmAXkUYCWi1
```  
* 注册runner (https://docs.gitlab.com/runner/register/index.html)
```
# docker注册
docker run --rm -t -i -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register \
  --non-interactive \
  --executor "docker" \
  --docker-image alpine:latest \
  --url "https://gitlab.dadi01.com/" \
  --tls-ca-file "/etc/gitlab-runner/certs/gitlab.dadi01.com.crt" \
  --registration-token "hxz2HxzY3D6MDLgBzHs5" \
  --description "shared-runner" \
  --tag-list "shared-runner,docker-runner" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected"
```
```
# shell命令行注册
sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.dadi01.com/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --tls-ca-file "/etc/gitlab-runner/certs/gitlab.dadi01.com.crt" \
  --executor "shell" \
  --description "ios-runner" \
  --tag-list "ios" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected"
```
* 为gitlab-runner启动的CI临时容器挂载文件目录
>vim /srv/gitlab-runner/config.toml
```
concurrent = 10   #限制同时可以运行多少个runner容器
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "shared-runner"
  url = "http://gitlab.dadi01.com/"
  tls-ca-file = "/etc/gitlab-runner/certs/gitlab.dadi01.com.crt"
  token = "028bde8ed782a413c4d2832f192c2d"
  executor = "docker"
  #强制git跳过ssl认证
  environment = ["GIT_SSL_NO_VERIFY=true"] 
  [runners.docker]
    image = "alpine:latest"
    tls_verify = false
    #在docker容器中使用的ssl证书
    #tls_cert_path = "/etc/docker/certs.d"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    # 将gitlab-runner物理机的文件挂载到CI临时容器
    volumes = [
        "/cache",
        "/var/run/docker.sock:/var/run/docker.sock",
        "/root/.kube/config:/root/.kube/config",
        "/root/.composer:/root/.composer:rw",
        "/root/.ssh/id_rsa:/root/.ssh/id_rsa:ro",
        "/root/.ssh/known_hosts:/root/.ssh/known_hosts:rw"
    ]
    shm_size = 0
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
```
```
docker restart gitlab-runner
```

### 配置Runner
https://docs.gitlab.com/ee/ci/runners/README.html

**cache**
* https://docs.gitlab.com/ee/ci/caching/