docker run -d --name rabbitmq \
  --restart=always \
  --hostname rabbit \
  -p 5672:5672 \
  -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=rabbit \
  -e RABBITMQ_DEFAULT_PASS=rabbitdd01 \
  rabbitmq:3-management

docker run -d --name rabbit-mqtt \
  --restart=always \
  --hostname rabbit-mqtt \
  -p 5673:5672 \
  -p 15673:15672 \
  -p 1883:1883 \
  -e RABBITMQ_DEFAULT_USER=rabbitmqtt \
  -e RABBITMQ_DEFAULT_PASS=rabbitmqttdd01 \
  cyrilix/rabbitmq-mqtt