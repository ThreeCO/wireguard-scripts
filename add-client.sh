#!/bin/bash

if [ $# -eq 0 ]
then
	echo "must pass a client name as an arg: add-client.sh new-client"
elsets/
	echo "Creating client config for: $1"
	mkdir -p clients/$1
	umask 077 && wg genkey > clients/$1/$1.priv
        cat clients/$1/$1.priv | wg pubkey > clients/$1/$1.pub
	wg genpsk > clients/$1/$1.pre
	
	key=$(cat clients/$1/$1.priv) 
	pub=$(cat clients/$1/$1.pub)
	pre=$(cat clients/$1/$1.pre)
	ip="10.0.0."$(expr $(cat clients/last-ip.txt | tr "." " " | awk '{print $4}') + 1)
	FQDN=$(hostname -f)
        SERVER_PUB_KEY=$(cat /etc/wireguard/server_public_key)
        cat clients/wg0-client.example.conf | sed -e 's/:CLIENT_IP:/'"$ip"'/' | sed -e 's|:CLIENT_KEY:|'"$key"'|' | sed -e 's|:SERVER_PUB_KEY:|'"$SERVER_PUB_KEY"'|' | sed -e 's|:SERVER_ADDRESS:|'"$FQDN"'|' > clients/$1/wg0.conf
	echo $ip > clients/last-ip.txt
	#cp SETUP.txt clients/$1/SETUP.txt
	#tar czvf clients/$1.tar.gz clients/$1
	echo "Created config!"
	echo "Adding peer"
	#sudo wg set wg0 peer $(cat clients/$1/$1.pub) allowed-ips $ip/32
	cat clients/wg0-server.example.conf | # to befinished  >> wg0.conf
	echo "Adding peer to hosts file"
	echo $ip" "$1 | sudo tee -a /etc/hosts
	sudo wg show
	qrencode -t ansiutf8 < clients/$1/wg0.conf
fi
