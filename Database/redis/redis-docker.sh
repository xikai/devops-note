docker run -d --name redis --restart=always -p 6379:6379 redis

docker run -it --network host --rm redis redis-cli