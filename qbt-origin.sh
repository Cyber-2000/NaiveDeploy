#!/usr/bin/env bash

set +e

install_qbt_o(){
TERM=ansi whiptail --title "安装中" --infobox "安装Qbt原版中..." 7 68
if [[ ${dist} == debian ]]; then
  apt-get update
  apt-get install qbittorrent-nox -y
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
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/qbittorrent-nox --profile=/etc/qbt
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

cpu_thread_count=$(nproc --all)
io_thread=$((${cpu_thread_count}*4))

if [[ $(systemctl is-active qbittorrent) == active ]]; then
qbtcookie=$(curl -i --header 'Referer: http://localhost:8080' --data 'username=admin&password=adminadmin' http://localhost:8080/api/v2/auth/login | grep set-cookie | cut -c13-48)
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22encryption%22:1%7D  --cookie "${qbtcookie}"
#curl http://localhost:8080/api/v2/app/version  --cookie "${qbtcookie}"
#curl http://localhost:8080/api/v2/app/preferences  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22async_io_threads%22:${io_thread}%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22preallocate_all%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22customize_trackers_list_url%22:%22https:%2f%2ftrackerslist.com%2fall.txt%22%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22auto_update_trackers_enabled%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22enable_multi_connections_from_same_ip%22:false%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22add_trackers_enabled%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22announce_to_all_tiers%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22announce_to_all_trackers%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22announce_to_all_trackers%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22limit_utp_rate%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22limit_tcp_overhead%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22limit_lan_peers%22:false%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22enable_os_cache%22:false%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22alternative_webui_enabled%22:false%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22alternative_webui_path%22:%22%2fusr%2fshare%2fnginx%2fqBittorrent%2fweb%2f%22%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22max_connec%22:-1%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22max_connec_per_torrent%22:-1%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22web_ui_address%22:%22127.0.0.1%22%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22validate_https_tracker_certificate%22:false%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22peer_tos%22:0%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22web_ui_password%22:%22${password1}%22%7D  --cookie "${qbtcookie}"
fi
}
