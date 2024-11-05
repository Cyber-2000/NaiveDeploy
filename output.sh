#!/usr/bin/env bash

set +e

prase_output(){

apt-get install unattended-upgrades -y

  cat > '/etc/apt/apt.conf.d/20auto-upgrades' << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
EOF

while [[ -z ${myip} ]]; do

curl --ipv4 --retry 3 https://api-ipv4.ip.sb/geoip -A Mozilla &> /root/.naive//ip2.json

myip="$( jq -r '.ip' "/root/.naive//ip2.json" )"
mycountry="$( jq -r '.country' "/root/.naive//ip2.json" )"
mycity="$( jq -r '.city' "/root/.naive//ip.json" )"
myip_org="$( jq -r '.isp' "/root/.naive//ip2.json" )"

done

clear
	cat > '/etc/profile.d/mymotd.sh' << EOF
#!/usr/bin/env bash
bold=\$(tput bold)
normal=\$(tput sgr0)
# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
###
domain="${domain}"
password1="${password1}"
neofetch
echo -e " --- 欢迎使用VPSToolBox 😀😀😀 --- "
echo -e " --- \${BLUE}服務狀態(Service Status)\${NOCOLOR} ---"
  if [[ \$(systemctl is-active wg-quick@wgcf.service) == active ]]; then
echo -e "Warp+ Teams:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active naive) == active ]]; then
echo -e "Naiveproxy:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active alist) == active ]]; then
echo -e "Alist:\t\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active netdata) == active ]]; then
echo -e "Netdata:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active fail2ban) == active ]]; then
echo -e "Fail2ban:\t\t 正常运行中"
  fi
if [[ -d /opt/alist ]]; then
echo -e " --- \${BLUE}Alist 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain:${trojanport}\${NOCOLOR}"
cd /opt/alist
./alist admin
cd
fi
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 9.9.9.10" >> /etc/resolv.conf
EOF
chmod +x /etc/profile.d/mymotd.sh
echo "" > /etc/motd
echo "Install complete!"
whiptail --title "Success" --infobox "安装成功 正在重启" 8 68
clear
reboot
}
