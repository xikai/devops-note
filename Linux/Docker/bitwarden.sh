# https://hub.docker.com/r/bitwardenrs/server
# https://github.com/dani-garcia/vaultwarden/wiki

docker pull bitwardenrs/server:latest

docker run -d --name bitwarden \
  -e ADMIN_TOKEN=l8FOfRwtcxPEpRYSUjwblerUt8dU6b/DfR4Z71pNnkoF4xPeZEzCstgV3uN/UMDS \   #openssl rand -base64 48
  -e SMTP_HOST=smtp.300.cn \
  -e SMTP_FROM=ddyw-devops@300.cn \
  -e SMTP_PORT=25 \
  -e SMTP_SSL=true \
  -e SMTP_USERNAME=ddyw-devops@300.cn \
  -e SMTP_PASSWORD='9^q#foRVuQ86&#pfpbhL' \
  -e DOMAIN=https://10.12.0.21:42363 \
  -e ROCKET_TLS='{certs="/ssl/bitwarden.crt",key="/ssl/bitwarden.key"}' \   #不推荐使用内置https功能
  -v /data/bitwarden_rs/bw-data/:/data/ \
  -v /data/bitwarden_rs/bw-data/ssl:/ssl/ \
  -p 42363:80 \
  --restart=always \
  bitwardenrs/server:latest