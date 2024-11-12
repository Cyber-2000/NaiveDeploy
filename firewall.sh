#!/usr/bin/env bash

set +e

openfirewall(){
TERM=ansi whiptail --title "配置中" --infobox "配置防火墙中..." 7 68
#policy
iptables -P INPUT ACCEPT &>/dev/null
iptables -P FORWARD ACCEPT &>/dev/null
iptables -P OUTPUT ACCEPT &>/dev/null
ip6tables -P INPUT ACCEPT &>/dev/null
ip6tables -P FORWARD ACCEPT &>/dev/null
ip6tables -P OUTPUT ACCEPT &>/dev/null
#flash
iptables -F &>/dev/null
ip6tables -F &>/dev/null

#block outgoing plain dns request
iptables -A OUTPUT -p udp -m udp -d 127.0.0.1 --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp -d 127.0.0.1 --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 53 -j DROP
iptables -A OUTPUT -p tcp -m tcp --dport 53 -j DROP
ip6tables -A OUTPUT -p udp -m udp --dport 53 -j DROP
ip6tables -A OUTPUT -p tcp -m tcp --dport 53 -j DROP

#tcp
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
#udp
iptables -A INPUT -p udp -m udp --dport 443 -j ACCEPT
#tcp6
ip6tables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
ip6tables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
#udp6
ip6tables -A INPUT -p udp -m udp --dport 443 -j ACCEPT

iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
iptables -A OUTPUT -p icmp --icmp-type timestamp-reply -j DROP

apt-get install nftables -y
apt-get install iptables-persistent -y
systemctl enable nftables.service
}