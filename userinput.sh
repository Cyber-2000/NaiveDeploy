#!/usr/bin/env bash

set +e

userinput_standard() {
  clear

  while [[ -z ${domain} ]]; do
    domain=$(whiptail --inputbox --nocancel "域名 Domain" 8 68 --title "域名设置" 3>&1 1>&2 2>&3)
  done
  clear
  rm -rf /etc/dhcp/dhclient.d/google_hostname.sh
  rm -rf /etc/dhcp/dhclient-exit-hooks.d/google_set_hostname
    while [[ -z ${password1} ]]; do
        password1=$(whiptail --inputbox --nocancel "Naiveproxy密码" 8 68 --title "密码设置" 3>&1 1>&2 2>&3 | sed 's/ //g')
        n=${#password1}
      if [[ ${n} > 30 ]] || [[ ${n} == 0 ]] || [[ ${n} -le 3  ]]  ; then
        password1=$(
          head /dev/urandom | tr -dc a-z0-9 | head -c 6
          echo ''
        )
      fi
    done
}
