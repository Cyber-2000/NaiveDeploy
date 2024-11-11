#!/usr/bin/env bash

set +e

install_peerbanhelper(){

cd $local_folder

mkdir /etc/pbh
mkdir /etc/pbh/data

  cat > '/etc/pbh/docker-compose.yml' << EOF
services:
  peerbanhelper:
    image: "ghostchu/peerbanhelper:v7.1.2"
    restart: unless-stopped
    container_name: "peerbanhelper"
    volumes:
      - /etc/pbh/data:/app/data
    ports:
      - "127.0.0.1:9898:9898"
    environment:
      - PUID=0
      - PGID=0
      - TZ=UTC
EOF

cd /etc/pbh
docker-compose up -d

cd $local_folder
}
