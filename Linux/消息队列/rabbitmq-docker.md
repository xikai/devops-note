```
docker run -d --name rabbitmq \
  --restart=always \
  --hostname rabbit \
  -p 5672:5672 \
  -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=rabbit \
  -e RABBITMQ_DEFAULT_PASS=rabbitdd01 \
  rabbitmq:3-management
```