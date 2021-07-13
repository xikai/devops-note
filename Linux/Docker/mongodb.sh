docker run -d --name mongo \
    --restart=always \
    -p 27017:27017 \
    -e MONGO_INITDB_ROOT_USERNAME=root \
    -e MONGO_INITDB_ROOT_PASSWORD=gotestdb \
    mongo


docker run -it --network host --rm mongo mongo test