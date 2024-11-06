```bash
apt -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update && apt-get install sudo git curl screen -y && cd && rm -rf NaiveDeploy && git clone https://github.com/Cyber-2000/NaiveDeploy.git && cd NaiveDeploy&& sudo screen -U bash main.sh
```