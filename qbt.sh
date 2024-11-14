#!/usr/bin/env bash

set +e

install_qbt(){
TERM=ansi whiptail --title "安装中" --infobox "安装Qbt中..." 7 68
if [[ ${dist} == debian ]]; then
  apt-get update
  # apt-get install qbittorrent-nox -y
  qbtver1=$(curl -s "https://api.github.com/repos/userdocs/qbittorrent-nox-static/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c1-13)
  curl -LO https://github.com/userdocs/qbittorrent-nox-static/releases/download/${qbtver1}_v1.2.19/x86_64-qbittorrent-nox
  cp x86_64-qbittorrent-nox /usr/bin/qbittorrent-nox
  chmod +x /usr/bin/qbittorrent-nox
  rm x86_64-qbittorrent-nox
 elif [[ ${dist} == ubuntu ]]; then
  add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y
  apt-get install qbittorrent-nox -y
 else
  echo "fail"
fi
 #useradd -r qbittorrent --shell=/usr/sbin/nologin
  cat > '/etc/systemd/system/qbittorrent.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=https://github.com/qbittorrent/qBittorrent
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/qbittorrent-nox --profile=/etc/qbt --confirm-legal-notice
TimeoutStopSec=infinity
LimitNOFILE=infinity
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable qbittorrent.service
mkdir /etc/qbt
mkdir /etc/qbt/qBittorrent/
mkdir /etc/qbt/qBittorrent/downloads/
mkdir /etc/qbt/qBittorrent/data/
mkdir /etc/qbt/qBittorrent/data/GeoIP/
chmod 755 /etc/qbt
systemctl restart qbittorrent.service
sleep 10

systemctl restart qbittorrent.service
sleep 10

while [[ -z $qbtpass ]]; do
qbtpass=$(journalctl -eu qbittorrent -n 7 | grep 'password is provided for this session' | awk '{ print $21 }')
done
cpu_thread_count=$(nproc --all)
io_thread=$((${cpu_thread_count}*4))

sleep 3

while [[ -z $qbtcookie  ]]; do
qbtcookie=$(curl -i --header 'Referer: http://localhost:8080' --data "username=admin&password=${qbtpass}" http://localhost:8080/api/v2/auth/login | grep set-cookie | cut -c13-48)
done

#curl http://localhost:8080/api/v2/app/preferences  --cookie "${qbtcookie}" | jq
# curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22customize_trackers_list_url%22:%22https:%2f%2ftrackerslist.com%2fall.txt%22%7D  --cookie "${qbtcookie}"
# curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22auto_update_trackers_enabled%22:true%7D  --cookie "${qbtcookie}"
# curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22alternative_webui_enabled%22:false%7D  --cookie "${qbtcookie}"
# curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22alternative_webui_path%22:%22%2fusr%2fshare%2fnginx%2fqBittorrent%2fweb%2f%22%7D  --cookie "${qbtcookie}"

curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"save_path":"/etc/qbt/qBittorrent/downloads/"}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"web_ui_address":"127.0.0.1"}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"add_trackers":"https://btn-prod.ghostchu-services.top/tracker/announce"}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"locale":"zh_CN"}'
#curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d "json={"web_ui_password":"${password1}"}"
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"add_trackers_enabled":true}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"idn_support_enabled":true}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"announce_to_all_trackers":true}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"bypass_local_auth":true}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"merge_trackers":true}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"web_ui_reverse_proxy_enabled":true}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"reannounce_when_address_changed":true}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"block_peers_on_privileged_ports":true}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"apply_ip_filter_to_trackers":true}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"encryption":1}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"peer_tos":0}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"socket_backlog_size":30000}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"file_pool_size":65535}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"max_connec":-1}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"max_uploads":-1}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"max_uploads_per_torrent":-1}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"max_connec_per_torrent":-1}'
curl http://localhost:8080/api/v2/app/setPreferences  --cookie "${qbtcookie}" -v -d 'json={"limit_lan_peers":false}'
systemctl restart qbittorrent.service
}
