#!/usr/bin/env bash

## Docker模组 Docker moudle

set +e

install_docker(){
TERM=ansi whiptail --title "安装中" --infobox "安装Docker中..." 7 68
colorEcho ${INFO} "安装Docker(Install Docker ing)"
apt-get update


if [[ ${dist} == debian ]]; then
  apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  cat >"/etc/apt/sources.list.d/docker.list" <<EOF
deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable
EOF
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
elif [[ ${dist} == ubuntu ]]; then
  apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  cat >"/etc/apt/sources.list.d/docker.list" <<EOF
deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOF
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
else
  echo "fail"
fi
#   cat > '/etc/docker/daemon.json' << EOF
# {
#   "metrics-addr" : "127.0.0.1:9323",
#   "experimental" : true
# }
# EOF
## Install Docker Compose

dockerver=$(curl --retry 5 -s "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl --retry 5 -L "https://github.com/docker/compose/releases/download/${dockerver}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
systemctl restart docker
}