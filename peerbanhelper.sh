#!/usr/bin/env bash

set +e

install_peerbanhelper(){

cd $local_folder

mkdir /etc/pbh
mkdir /etc/pbh/data
mkdir /etc/speed
mkdir /etc/speed/data

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
  speedtest:
    container_name: speedtest
    image: ghcr.io/librespeed/speedtest:latest
    restart: always
    volumes:
      - /etc/speed/data:/database
    environment:
      MODE: standalone
      TITLE: "NaiveSpeed"
      TELEMETRY: "true"
      #ENABLE_ID_OBFUSCATION: "false"
      #REDACT_IP_ADDRESSES: "false"
      PASSWORD: "123456"
      EMAIL: "example@example.com"
      #DISABLE_IPINFO: "false"
      IPINFO_APIKEY: "56c375418c62c9"
      DISTANCE: "km"
      #WEBPORT: 80
    ports:
      - "127.0.0.1:6666:80" # webport mapping (host:container)
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

cat config.yml | yq '.pbh-plus-key = SXXuMG2ZsxIhai1HK6IX97G5sXxHDQMBMyNzgOcSux6lVI3+pLPqAaQCbM9GnM6YsgfjmjYXMnO+x7cnkklGOGaip7/ZlEoirMb6PRohNKtNV88NDhyWexFvVseKHcU8qT3e7MQJBZeCoRTbhWL25jLoKPDhFA5YSWLTZJBSJAs/M8t8+52VJWx7ZhlIZk0yQ1qn5UuvNZMAz4I+6fc3YtLPVg7XwHc6T6Ih7KcQvNaa9V64AcJ/c5MsQf2lBYc4dWgO3HWpVXaMkHWE0TDi83qt60E/AXBfCPE2umjU6Rm9MwJxpC8eb1eAjrETfz7gKqixVTDzoRgwSm5JSlzFmy42jk8cRPbIAbqiEWlVECU0YIkUD18znM6/yezcQVKJa+pynHCpnCVx1Lgy2sh320CZfxZfz9fvFIVparSJgcrB/ep85OuYz5QL4LnzrYi5zD+38NpfHUw6iEMdGD5I/Fw0Ah6Wic3IRwiC/i7RIVXTL1vGxkGmcZDImuCoH1d3' -y &> tmp.yml
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
echo "    ignore-private: true" >>config.yml
else
echo 0
fi

cd /etc/pbh
docker-compose restart

cd $local_folder
}
