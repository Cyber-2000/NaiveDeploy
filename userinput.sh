#!/usr/bin/env bash

set +e

userinput_standard() {

ping baidu.com -c 4

  if [[ $? != 0 ]]; then
    TERM=ansi whiptail --title "GFW check fail" --msgbox "GFW check fail , be alert." 7 68
  fi
  while [[ -z ${domain} ]]; do
    domain=$(whiptail --inputbox --nocancel "域名 Domain" 8 68 --title "域名设置" 3>&1 1>&2 2>&3)
    if whiptail --title "Domain check" --yesno "Confirm to use  ${domain}  ?" 8 78; then
      echo "User confirmed complete."
    else
      domain=""
    fi
    validate="^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$"
    if [[ "$domain" =~ $validate ]]; then
      echo "Valid $domain name."
    else
      echo "Not valid $domain name."
      domain=""
    fi
  done
  
  rm -rf /etc/dhcp/dhclient.d/google_hostname.sh
  rm -rf /etc/dhcp/dhclient-exit-hooks.d/google_set_hostname
    while [[ -z ${password1} ]]; do
        password1=$(whiptail --inputbox --nocancel "Naiveproxy密码" 8 68 --title "密码设置" 3>&1 1>&2 2>&3 | sed 's/ //g')
        n=${#password1}
    done
}
