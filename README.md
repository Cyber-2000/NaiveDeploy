```bash
apt -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update && apt-get install sudo git curl screen -y && cd && rm -rf NaiveDeploy && git clone https://github.com/Cyber-2000/NaiveDeploy.git && cd NaiveDeploy&& sudo bash main.sh
```

Debian or Ubuntu only.

Warning: Naiveproxy does not support cloudflare CDN , use at caution.

System requirement(minimal):

1. 1 CPU thread (2.7 Ghz+)
2. 1 GB RAM
3. 20 GB DISK SPACE (SSD only)
4. 1 IPv4 address (80 & 443 port must available)
5. 1 domain name (resolved to current IPv4 address)

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