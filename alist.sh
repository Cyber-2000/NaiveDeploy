#!/usr/bin/env bash

## Alist模组

set +e

install_alist(){
    if [[ -d /opt/alist ]]; then
        curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s update
    else
        curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install
    fi

  cat > '/etc/systemd/system/alist.service' << EOF
[Unit]
Description=Alist service
Wants=network.target
After=network.target network.service

[Service]
Type=simple
WorkingDirectory=/opt/alist
ExecStart=/opt/alist/alist server
KillMode=process
LimitNOFILE=infinity
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable alist
systemctl restart alist

cd /opt/alist/data
cat config.json | jq '.scheme.address = "127.0.0.1"' &> tmp.json
cp tmp.json config.json
rm tmp.json

cat config.json | jq  '."site_url" = "'"https://$domain"'"' &> tmp.json
cp tmp.json config.json
rm tmp.json

cat config.json | jq '.tls_insecure_skip_verify = false' &> tmp.json
cp tmp.json config.json
rm tmp.json

cd $local_folder

systemctl restart alist

sleep 4

cd /opt/alist/

./alist admin set ${password1} --data /opt/alist/data

cd $local_folder
}
