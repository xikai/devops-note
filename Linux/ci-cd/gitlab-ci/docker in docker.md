```
build_image:
  stage: build_image
  image: docker:stable   #image中需要有docker命令
  variables:
    DOCKER_DRIVER: overlay2
    DOCKER_HOST: tcp://docker:2375
  services:
    - docker:18.09-dind
```