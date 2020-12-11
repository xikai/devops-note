# https://github.com/pantsel/konga#installation

docker run -d \
     -p 1337:1337 \
     -e "DB_ADAPTER=postgres" \
     -e "DB_HOST=pgm-wz92e12y33u2gj7w14810.pg.rds.aliyuncs.com" \
     -e "DB_PORT=3433" \
     -e "DB_USER=kong" \
     -e "DB_PASSWORD=k0ngAPIgw" \
     -e "DB_DATABASE=konga_database" \
     -e "NODE_ENV=development" \
     --name kong_dashboard \
     pantsel/konga