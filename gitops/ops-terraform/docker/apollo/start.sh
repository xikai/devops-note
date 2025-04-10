#!/bin/bash

DB_USERNAME=apollo
DB_PASSWORD=123456
DB_URL=127.0.0.1
DB_PORT=3306
APOLLO_LOGS=/data/apollo/logs

mkdir -pv ${APOLLO_LOGS}

# apollo config service

docker run --network host \
-e SPRING_DATASOURCE_URL="jdbc:mysql://${DB_URL}:${DB_PORT}/ApolloConfigDB?characterEncoding=utf8&useSSL=false"    \
-e SPRING_DATASOURCE_USERNAME=${DB_USERNAME} -e SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}     \
-d -v ${APOLLO_LOGS}:/opt/logs --name apollo-configservice $1/apollo-configservice

sleep 120

# apollo admin service

docker run --network host \
-e SPRING_DATASOURCE_URL="jdbc:mysql://${DB_URL}:${DB_PORT}/ApolloConfigDB?characterEncoding=utf8&useSSL=false" \
-e SPRING_DATASOURCE_USERNAME=${DB_USERNAME} -e SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD} \
-d -v ${APOLLO_LOGS}:/opt/logs --name apollo-adminservice $1/apollo-adminservice

sleep 60


# apollo portal service

docker run --network host  \
    -e SPRING_DATASOURCE_URL="jdbc:mysql://${DB_URL}:${DB_PORT}/ApolloPortalDB?characterEncoding=utf8&useSSL=false" \
    -e SPRING_DATASOURCE_USERNAME=${DB_USERNAME} -e SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD} \
    -e APOLLO_PORTAL_ENVS=dev \
    -e DEV_META=http://127.0.0.1:8080 \
    -d -v ${APOLLO_LOGS}:/opt/logs --name apollo-portal $1/apollo-portal
