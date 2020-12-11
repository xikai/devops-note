```
job:
  image: registry-vpc.cn-shenzhen.aliyuncs.com/dd01/alpine:latest
  script:
    - echo "Deploy to server"
    - rsync -avzp --delete --partial --exclude='.git/' -e "ssh -p 28 -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no" ./ root@47.107.91.47:/srv/$CI_PROJECT_NAME |grep -v /$
  only:
  - master@web/dd01-sites
```