#!/usr/bin/env bash

set +e

install_naive(){

TERM=ansi whiptail --title "安装中" --infobox "安装Naiveproxy" 7 68
systemctl stop caddy
wget "https://dl.google.com/go/$(curl https://go.dev/VERSION?m=text -s | head -1).linux-amd64.tar.gz"
rm -rf /usr/local/go && tar -C /usr/local -xzf *.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
~/go/bin/xcaddy build --with github.com/caddyserver/forwardproxy=github.com/klzgrad/forwardproxy@naive
cp caddy /usr/bin/
/usr/bin/caddy version
setcap cap_net_bind_service=+ep /usr/bin/caddy
rm *.linux-amd64.tar.gz
rm caddy
rm -rf go

  cat > '/etc/systemd/system/caddy.service' << EOF
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=infinity
LimitNPROC=512
AmbientCapabilities=CAP_NET_BIND_SERVICE
Restart=always
RestartSec=3s
CPUSchedulingPolicy=fifo
CPUSchedulingPriority=99
IOSchedulingClass=realtime
StandardOutput=null
StandardError=null

Nice=-20
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable caddy
mkdir /etc/caddy/
    cat > '/etc/caddy/Caddyfile' << EOF

{
        order forward_proxy before route
        log default {
                output file /etc/caddy/caddy.log {
                }

                format json
        }
}

:80 {
  redir https://{host}{uri}
}

:443, ${domain} {

        forward_proxy {
                basic_auth alpha $password1
                hide_ip
                hide_via
                probe_resistance
                dial_timeout     30
        }

        @host {
                host ${domain}
        }
        route @host {
                header {
                        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
                        # disable clients from sniffing the media type
                        X-Content-Type-Options nosniff
                        # clickjacking protection
                        Referrer-Policy no-referrer

                        -Server
                }
                encode zstd gzip
                redir /${password1}_speed /${password1}_speed/
                handle_path /${password1}_speed/* {
                        reverse_proxy http://127.0.0.1:6666
                }
                redir /${password1}_nzb /${password1}_nzb/
                handle_path /${password1}_nzb/* {
                        reverse_proxy http://127.0.0.1:3511
                }
                redir /${password1}_qbt /${password1}_qbt/
                handle_path /${password1}_qbt/* {
                        reverse_proxy http://127.0.0.1:8080
                }
                redir /${password1}_i2pd /${password1}_i2pd/
                handle_path /${password1}_i2pd/* {
                        reverse_proxy http://127.0.0.1:7070
                }
                redir /${password1}_pbh /${password1}_pbh/
                handle_path /${password1}_pbh/* {
                        reverse_proxy http://127.0.0.1:9898
                }
                reverse_proxy http://127.0.0.1:5244 {
                }
        }
}
EOF
cd /etc/caddy/
caddy fmt --overwrite
cd $local_folder
chmod -R 755 /etc/caddy/
systemctl daemon-reload
systemctl restart caddy
}

