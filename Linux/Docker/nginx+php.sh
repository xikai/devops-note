mkdir -p /data/www

docker run --name web_nginx -p 80:80 -p 443:443 -d \
    --restart=always \
    -v /data/www:/data/www:ro \
    -v /srv/nginx/conf.d:/etc/nginx/conf.d:ro \
    --link web_php:php \
    nginx

docker run --name web_php -d \
    --restart=always \
    -v /data/www:/data/www:rw \
    dadi01/php:7.1

