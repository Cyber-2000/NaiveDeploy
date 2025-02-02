#!/usr/bin/env bash



set +e

export DEBIAN_FRONTEND=noninteractive
export COMPOSER_ALLOW_SUPERUSER=1

if [[ $(id -u) != 0 ]]; then
  echo -e "Please run as root or sudoer."
  exit 1
fi

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
###Legacy Defined Colors
ERROR="31m"   # Error message
SUCCESS="32m" # Success message
WARNING="33m" # Warning message
INFO="36m"    # Info message
LINK="92m"    # Share Link Message

rm -rf /lib/systemd/system/cloud*

colorEcho() {
  COLOR=$1
  echo -e "\033[${COLOR}${@:2}\033[0m"
}

#设置系统语言
setlanguage() {
  mkdir /root/.naive//
  mkdir /etc/certs/
  chattr -i /etc/locale.gen
  cat >'/etc/locale.gen' <<EOF
C.UTF-8 UTF-8
#zh_CN.UTF-8 UTF-8
#zh_TW.UTF-8 UTF-8
#en_US.UTF-8 UTF-8
#ja_JP.UTF-8 UTF-8
EOF
  locale-gen
  update-locale
  chattr -i /etc/default/locale
  cat >'/etc/default/locale' <<EOF
LANGUAGE="C.UTF-8"
LANG="C.UTF-8"
LC_ALL="C.UTF-8"
EOF
  export LANGUAGE="C.UTF-8"
  export LANG="C.UTF-8"
  export LC_ALL="C.UTF-8"
}

initialize() {
  if [[ -f /etc/sysctl.d/60-disable-ipv6.conf ]]; then
    mv /etc/sysctl.d/60-disable-ipv6.conf /etc/sysctl.d/60-disable-ipv6.conf.bak
  fi
  if cat /etc/*release | grep ^NAME | grep -q Ubuntu; then
    dist="ubuntu"
    if [[ -f /etc/sysctl.d/60-disable-ipv6.conf.bak ]]; then
      sed -i 's/#//g' /etc/netplan/01-netcfg.yaml
      netplan apply
    fi
    apt-get update
    apt-get install sudo whiptail curl dnsutils locales lsb-release jq -y
  elif cat /etc/*release | grep ^NAME | grep -q Debian; then
    dist="debian"
    apt-get update
    apt-get install sudo whiptail curl dnsutils locales lsb-release jq -y
  else
    echo -e "Please use Debian or Ubuntu."
    exit 1
  fi

  ## SSH 连接保活

  sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" /etc/ssh/sshd_config
  sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 3/g" /etc/ssh/sshd_config

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

  systemctl reload sshd

  ## 阻止日志文件过大占用系统空间

  if grep "maxsize" /etc/logrotate.d/rsyslog; then

    echo "日志最大大小设置已存在"

  else

    sed -e "/weekly/a\\
	maxsize 1G" </etc/logrotate.d/rsyslog >tmp

    cp -f tmp /etc/logrotate.d/rsyslog

    cat /etc/logrotate.d/rsyslog

    rm tmp

  fi

  rm -rf /usr/local/sa
  rm -rf /usr/local/agenttools
  rm -rf /usr/local/qcloud
  rm -rf /usr/local/telescope

  cat /etc/apt/sources.list | grep aliyun &>/dev/null

  if [[ $? == 0 ]] || [[ -d /usr/local/aegis ]]; then
    source uninstall-aegis.sh
    uninstall_aegis
  fi

  localip=$(ip -4 a | grep inet | grep "scope global" | awk '{print $2}' | cut -d'/' -f1 | head -n 1)
  myipv6=$(ip -6 a | grep inet6 | grep "scope global" | awk '{print $2}' | cut -d'/' -f1 | head -n 1)
  # myip="$(jq -r '.ip' "/root/.naive//ip.json")"
  # mycountry="$(jq -r '.country' "/root/.naive//ip.json")"
  # mycity="$(jq -r '.city' "/root/.naive//ip.json")"

  # myip_org="$(jq -r '.org' "/root/.naive//ip.json")"

  # IFS=' '

  # read -a strarr <<<"$myip_org"

  # org_temp="${strarr[1]}"

  # IFS=' '

  # read -a strarr2 <<<"$org_temp"

  # org="${strarr2[0]}"
}

install_base() {
  set +e
  apt-get update
  apt-get install sudo git curl xz-utils wget apt-transport-https gnupg lsb-release unzip ntpdate systemd dbus ca-certificates locales iptables software-properties-common cron e2fsprogs less neofetch -y
  apt-get install bc -y
  
}

MasterMenu() {
    chattr -i -f /etc/resolv.conf
    # echo "nameserver 1.1.1.1" >/etc/resolv.conf
    # echo "nameserver 9.9.9.10" >>/etc/resolv.conf    
    cfdver1=$(curl -s "https://api.github.com/repos/cloudflare/cloudflared/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -LO https://github.com/cloudflare/cloudflared/releases/download/${cfdver1}/cloudflared-linux-amd64.deb
    dpkg -i cloudflared*.deb
    rm cloudflared*.deb
  cat > '/etc/systemd/system/cloudflared-proxy-dns.service' << EOF
[Unit]
Description=DNS over HTTPS (DOH) proxy client
Wants=network-online.target nss-lookup.target
Before=nss-lookup.target

[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
ExecStart=/usr/local/bin/cloudflared proxy-dns --max-upstream-conns 0
DynamicUser=yes
LimitNOFILE=infinity
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable cloudflared-proxy-dns --now
    echo "nameserver 127.0.0.1" >/etc/resolv.conf
    chattr +i -f /etc/resolv.conf
    mkdir -p /etc/systemd/resolved.conf.d/
  cat > '/etc/systemd/resolved.conf.d/disable-stub.conf' << EOF
[Resolve]
DNSStubListener=no
EOF
    systemctl disable systemd-resolved.service --now
    source userinput.sh
    userinput_standard
    apt update
    apt upgrade -y
    source bbr.sh
    install_bbr
    install_base
    source firewall.sh
    openfirewall
    source naive.sh
    install_naive
    # source docker.sh
    # install_docker
    # source aria2.sh
    # install_aria2
    # source peerbanhelper.sh
    # install_peerbanhelper
    #source qbt.sh
    #install_qbt
    source alist.sh
    install_alist
    apt-get install neofetch -y
    cd $local_folder
    source output.sh
    prase_output
    exit 0
}

#sed -i "s/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/g" /etc/gai.conf

local_folder=$(pwd)

# mkdir /root/.naive/
# curl --ipv4 --retry 3 -s https://ipinfo.io?token=56c375418c62c9 --connect-timeout 5 &>/root/.naive/ip.json
initialize
setlanguage
MasterMenu
