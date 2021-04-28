mkdir -p /data/mysql/data
mkdir -p /data/mysql/conf

docker run -d --name mysql5.7 \
    --restart=always \
    -p 3306:3306 \
    -v /data/mysql/conf:/etc/mysql/conf.d \
    -v /data/mysql/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=dadi123456 \
    --character-set-server=utf8 \ --collation-server=utf8_general_ci \
    mysql:5.7