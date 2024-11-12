```bash
apt -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update && apt-get install sudo git curl screen -y && cd && rm -rf NaiveDeploy && git clone https://github.com/Cyber-2000/NaiveDeploy.git && cd NaiveDeploy&& sudo bash main.sh
```

Debian or Ubuntu only.

Run as root.

Run in a vps , do not use host or production machine unless you know what you are doing.

Contains following system components:

1. Naiveproxy(Caddy version) 
2. Alist 
3. Qbittorrent[with Peerbanhelper(Docker version)] 
4. Aria2 
5. Cloudflared DOH Client
6. BBR TCP Optimization

All in one script, no manual config required.

No guarantee, no technical support , strict self management only.

If any error occured , submit github issue , thanks.