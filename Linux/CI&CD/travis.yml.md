```
language: php
php: 7.1

group: stable
dist: trusty
os: linux
sudo: required

install:
  - composer global require hirak/prestissimo
  - composer install
before_install:
  - pecl install mongodb

cache:
  directories:
    - $HOME/.composer/cache/files

branches:
  only:
    - master
    - /^development.*/

before_deploy:
  - >
    if ! [ "${BEFORE_DEPLOY_RUN}" ]; then
      export BEFORE_DEPLOY_RUN=1;

      tar -czf latest.tgz *
      mkdir -p s3_upload/${TRAVIS_REPO_SLUG}
      mv latest.tgz s3_upload/${TRAVIS_REPO_SLUG}/${TRAVIS_BRANCH}-${TRAVIS_BUILD_NUMBER}.tgz
    fi

deploy:
  #- provider: s3
  #  access_key_id: ${AWS_S3_ACCESS_KEY_ID_SWAGGER}
  #  secret_access_key: ${AWS_S3_SECRET_ACCESS_KEY_SWAGGER}
  #  bucket: wemedia01-swagger-doc
  #  region: ap-southeast-1
  #  local_dir: s3_swagger_upload
  #  upload_dir: ${TRAVIS_REPO_SLUG}/${TRAVIS_BRANCH}
  #  skip_cleanup: true
  #  on:
  #    branch:
  #      - development
  #      - master
  - provider: s3
    access_key_id: &1
      ${AWS_S3_ACCESS_KEY_ID_DEVELOPMENT_1}
    secret_access_key: &2
      ${AWS_S3_SECRET_ACCESS_KEY_DEVELOPMENT_1}
    bucket: &3
      ${AWS_S3_BUCKET_DEVELOPMENT_1}
    region: &4
      ap-southeast-1
    local_dir: s3_upload
    skip_cleanup: true
    on: &5
      branch:
        - development
  - provider: codedeploy
    access_key_id: *1
    secret_access_key: *2
    bucket: *3
    region: *4
    key: ${TRAVIS_REPO_SLUG}/${TRAVIS_BRANCH}-${TRAVIS_BUILD_NUMBER}.tgz
    bundle_type: tgz
    application: ${AWS_CODEDEPLOY_APPLICATION_DEVELOPMENT_1}
    deployment_group: staging
    on: *5

  - provider: s3
    access_key_id: &6
      ${AWS_S3_ACCESS_KEY_ID_PRODUCTION}
    secret_access_key: &7
      ${AWS_S3_SECRET_ACCESS_KEY_PRODUCTION}
    bucket: &8
      ${AWS_S3_BUCKET_PRODUCTION}
    region: &9
      ap-southeast-1
    local_dir: s3_upload
    skip_cleanup: true
    on: &10
      branch:
        - master
  - provider: codedeploy
    access_key_id: *6
    secret_access_key: *7
    bucket: *8
    region: *9
    key: ${TRAVIS_REPO_SLUG}/${TRAVIS_BRANCH}-${TRAVIS_BUILD_NUMBER}.tgz
    bundle_type: tgz
    application: ${AWS_CODEDEPLOY_APPLICATION_PRODUCTION}
    deployment_group: production
    on: *10


```