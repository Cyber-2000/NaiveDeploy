#!/usr/bin/env bash

set +e

prase_output(){

apt-get install fail2ban -y
if grep -q "DebianBanner" /etc/ssh/sshd_config; then
    :
else
    #ssh-keygen -A
    sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
    #sed -i 's/^HostKey \/etc\/ssh\/ssh_host_\(dsa\|ecdsa\)_key$/\#HostKey \/etc\/ssh\/ssh_host_\1_key/g' /etc/ssh/sshd_config
    #sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config
    #sed -i 's/#TCPKeepAlive yes/TCPKeepAlive yes/' /etc/ssh/sshd_config
    #sed -i 's/#PermitTunnel no/PermitTunnel no/' /etc/ssh/sshd_config
    #sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
    #sed -i 's/#GatewayPorts no/GatewayPorts no/' /etc/ssh/sshd_config
    #sed -i 's/#StrictModes yes/StrictModes yes/' /etc/ssh/sshd_config
    #sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/' /etc/ssh/sshd_config
    #sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config
    echo "" >>/etc/ssh/sshd_config
    #echo "Protocol 2" >> /etc/ssh/sshd_config
    echo "DebianBanner no" >>/etc/ssh/sshd_config
    #echo "AllowStreamLocalForwarding no" >> /etc/ssh/sshd_config
    systemctl reload sshd
fi

apt-get install unattended-upgrades -y

  cat > '/etc/apt/apt.conf.d/20auto-upgrades' << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
EOF

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
echo -e " --- \${BLUE}服務狀態(Service Status)\${NOCOLOR} ---"
  if [[ \$(systemctl is-active cloudflared-proxy-dns) == active ]]; then
echo -e "Cloudflared DOH:\t 正常运行中"
  fi
  if [[ \$(systemctl is-active caddy) == active ]]; then
echo -e "Naiveproxy:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active qbittorrent) == active ]]; then
echo -e "Qbittorrent:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active aria2) == active ]]; then
echo -e "Aria2:\t\t\t 正常运行中"
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
echo -e " --- \${BLUE}Naiveproxy 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}naive+quic://alpha:${password1}@${domain}:443"
echo -e " --- \${BLUE}Alist 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain\${NOCOLOR} | ${password1}"
echo -e " --- \${BLUE}Qbittorrent 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain/${password1}_qbt/\${NOCOLOR}"
echo -e " --- \${BLUE}PeerBanHelper 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain/${password1}_pbh/\${NOCOLOR}"
EOF
chmod +x /etc/profile.d/mymotd.sh
echo "" > /etc/motd
echo "Install complete! Reboot now."

cd $local_folder

cd ..

rm -rf NaiveDeploy

TERM=ansi whiptail --title "配置完成" --infobox "正在重启" 7 68

reboot
}
