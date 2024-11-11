#!/usr/bin/env bash

set +e

install_peerbanhelper(){

cd $local_folder

mkdir /etc/pbh
mkdir /etc/pbh/data

  cat > '/etc/pbh/docker-compose.yml' << EOF
services:
  peerbanhelper:
    image: "ghostchu/peerbanhelper:latest"
    network_mode: host
    restart: unless-stopped
    container_name: "peerbanhelper"
    volumes:
      - /etc/pbh/data:/app/data
    environment:
      - PUID=0
      - PGID=0
      - TZ=UTC
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
EOF

cd /etc/pbh
docker-compose up -d

apt-get install yq -y

sleep 10

cd /etc/pbh/data/config

cat config.yml | yq '.server.address = "127.0.0.1"' -y &> tmp.yml
cp tmp.yml config.yml
rm tmp.yml

cat config.yml | yq '.proxy.setting = 0' -y &> tmp.yml
cp tmp.yml config.yml
rm tmp.yml

cat config.yml | yq '."server"."token" = "'"$password1"'"' -y &> tmp.yml
cp tmp.yml config.yml
rm tmp.yml

cat config.yml | grep qbittorrent
if [ $? != 0 ];then
echo 1
echo "client:" >>config.yml
echo "  local:" >>config.yml
echo "    type: qbittorrent" >>config.yml
echo "    endpoint: http://127.0.0.1:8080" >>config.yml
echo "    basic-auth:" >>config.yml
echo "      user: ''" >>config.yml
echo "      pass: ''" >>config.yml
echo "    http-version: HTTP_2" >>config.yml
echo "    increment-ban: true" >>config.yml
echo "    use-shadow-ban: false" >>config.yml
echo "    verify-ssl: true" >>config.yml
echo "    ignore-private: false" >>config.yml
else
echo 0
fi

cd /etc/pbh
docker-compose restart

cd $local_folder
}
