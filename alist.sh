#!/usr/bin/env bash

set +e

install_alist(){
    if [[ -d /opt/alist ]]; then
        curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s update
    else
        curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install
    fi

systemctl enable alist

sleep 10

apt install jq -y

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

sleep 10

cd /opt/alist/

./alist admin set ${password1} --data /opt/alist/data

cd $local_folder
}
