```
variables:
  PROJECT_NAME: "per-api"
  HOST_PRODUCTION_1: "47.112.28.116"
  HOST_PRODUCTION_2: "47.106.75.85"

stages:
  - test
  - build_image
  - deploy

test_production:
  stage: test
  image: registry-vpc.cn-shenzhen.aliyuncs.com/dd01/php:7.2
  cache:
    key: "$CI_COMMIT_REF_NAME"
    paths:
      - vendor/
  before_script:
    - composer install
  script:
    - echo "test stage"
  only:
    - master@web/per-dadi01-net

deploy_production:
  stage: deploy
  image: registry-vpc.cn-shenzhen.aliyuncs.com/dd01/alpine:latest
  cache:
    key: "$CI_COMMIT_REF_NAME"
    paths:
      - vendor/
    policy: pull
  before_script:
    - git clone --depth 1 ssh://git@gitlab.dadi01.com:28/yejunyi/prod-config.git
    - cp prod-config/prod-site-config/per-dadi01-com.stg .env
    - rm -rf prod-config
  script:
    - echo "Deploy to production server"
    - rsync -avzp --delete --partial --exclude='.git/' -e "ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no" ./ root@$HOST_PRODUCTION_1:/srv/$CI_PROJECT_NAME |grep -v /$
    - rsync -avzp --delete --partial --exclude='.git/' -e "ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no" ./ root@$HOST_PRODUCTION_2:/srv/$CI_PROJECT_NAME |grep -v /$
  environment:
    name: production
    url: http://per-api.fncul.com
  only:
  - master@web/per-dadi01-net


##############
test:
  stage: test
  image: reg.dadi01.cn/library/php:7.2
  tags:
    - xinnet-runner
  cache:
    key: "$CI_COMMIT_REF_NAME"
    paths:
      - vendor/
  before_script:
    - composer install
  script:
    - echo "test stage xinnet"
  only:
    - /^release.*$/@web/per-dadi01-net
    - development@web/per-dadi01-net

build_image:
  stage: build_image
  image: reg.dadi01.cn/library/docker:18.09
  tags:
    - xinnet-runner
  cache:
    key: "$CI_COMMIT_REF_NAME"
    paths:
      - vendor/
    policy: pull
  script:
    - ls -a
    - docker login -u $HARBOR_USER -p $HARBOR_PWD reg.dadi01.cn
    - |-
      if [ $CI_COMMIT_REF_NAME == "development" ]; then
        docker build -t reg.dadi01.cn/test/$PROJECT_NAME:$CI_COMMIT_SHORT_SHA .
        docker push reg.dadi01.cn/test/$PROJECT_NAME:$CI_COMMIT_SHORT_SHA
      fi
      if echo $CI_COMMIT_REF_NAME | grep -q "release"; then
        docker build -t reg.dadi01.cn/staging/$PROJECT_NAME:$CI_COMMIT_SHORT_SHA .
        docker push reg.dadi01.cn/staging/$PROJECT_NAME:$CI_COMMIT_SHORT_SHA
      fi
  only:
    - /^release.*$/@web/per-dadi01-net
    - development@web/per-dadi01-net

deploy_test:
  stage: deploy
  image: reg.dadi01.cn/library/helm-kubectl:latest
  tags:
    - xinnet-runner
  script:
    - helm init --client-only --skip-refresh
    - cd helm/chart
    - sed -i "s/PARAM-WWWROOT/$PROJECT_NAME/" values-test.yaml
    - sed -i "s/PARAM-TAGS/$CI_COMMIT_SHORT_SHA/" values-test.yaml
    - helm dep update .
    - export DEPLOYS=$(helm ls |awk '{print $1}' |grep "^qa-$PROJECT_NAME$" |wc -l)
    - if [ ${DEPLOYS}  -eq 0 ]; then helm install --name="qa-$PROJECT_NAME" -f values-test.yaml . --namespace=kube-test; else helm upgrade -f values-test.yaml qa-$PROJECT_NAME . --namespace=kube-test; fi
  environment:
    name: test
    url: http://per-api.dadi01.net
  only:
    - development@web/per-dadi01-net

deploy_staging:
  stage: deploy
  image: reg.dadi01.cn/library/helm-kubectl:latest
  tags:
    - xinnet-runner
  script:
    - helm init --client-only --skip-refresh
    - cd helm/chart
    - sed -i "s/PARAM-WWWROOT/$PROJECT_NAME/" values-staging.yaml
    - sed -i "s/PARAM-TAGS/$CI_COMMIT_SHORT_SHA/" values-staging.yaml
    - helm dep update .
    - export DEPLOYS=$(helm ls |awk '{print $1}' |grep "^stg-$PROJECT_NAME$" |wc -l)
    - if [ ${DEPLOYS}  -eq 0 ]; then helm install --name="stg-$PROJECT_NAME" -f values-staging.yaml . --namespace=kube-staging; else helm upgrade -f values-staging.yaml stg-$PROJECT_NAME . --namespace=kube-staging; fi
  environment:
    name: staging
    url: http://per-api.dadi01.cn
  only:
    - /^release.*$/@web/per-dadi01-net
```