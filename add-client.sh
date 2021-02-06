#!/bin/bash

wg_name  = "wg0"
srv_host = "172.0.0.1"         # external IP of Wireguard
srv_port = 5280                # external Port of Wireguard
cl_dns   = "127.0.0.1"         # which DNS-Server shall be used?
cl_ip    = "10.0.0."           # subnet of client ips; please omit last number
cl_allowed = "192.10.10.0/32"  # IP for SPLIT-Tunnel / RoadWarrior


if [ $# -eq 0 ]
then
	echo "must pass a client name as an arg: add-client.sh new-client"
	echo "optionally you can add 'true' as second parameter for site to site - tunnel; standard is roadwarrior"
else
	echo "Creating client config for: $1"
	mkdir -p clients/$1
	umask 077 && wg genkey > clients/$1/$1.priv
        cat clients/$1/$1.priv | wg pubkey > clients/$1/$1.pub
	wg genpsk > clients/$1/$1.pre
	
	cl_priv = $(cat clients/$1/$1.priv) 
	cl_pub  = $(cat clients/$1/$1.pub)
	cl_pre  = $(cat clients/$1/$1.pre)
	cl_ip   = $cl_ip""$(expr $(cat clients/last-ip.txt | tr "." " " | awk '{print $4}') + 1)
	cl_sts  = "0.0.0.0/0"
        srv_pub = $(cat /etc/wireguard/server_public_key)
	
	if [ $2 -eq "true"]
        then
	  cl_allowed = $cl_sts
	fi
	
        cat clients/wg0-client.example.conf | sed -e 's/:CLIENT_IP:/'"$cl_ip"'/' | sed -e 's|:CLIENT_KEY:|'"$cl_priv"'|' | sed -e 's|:SERVER_PUB_KEY:|'"$srv_pub"'|' | sed -e 's|:PRESHARED_KEY:|'"$pub_pre"'|' | sed -e 's|:ALLOWED_IPS:|'"$cl_allowed"'|' | sed -e 's|:SERVER_ADDRESS:|'"$srv_host"'|' | sed -e 's|:SERVER_PORT:|'"$srv_port"'|' > clients/$1/wg0.conf
	echo $ip > clients/last-ip.txt
	echo "Created config!"
	
	echo "Adding peer to wg-conf"
	# append peer to wg0.conf
	cat clients/wg0-server.example.conf | # to befinished  >> wg0.conf
	
	echo "Adding peer to hosts file"
	echo $ip" "$1 | sudo tee -a /etc/host

        # resyncing wireguard 
        sudo wg syncconf $wg_name <(wg-quick strip $wg_name)
	
	sudo wg show $wg_name
	
	# generate qr-code for peer / client
	qrencode -t ansiutf8 < clients/$1/wg0.conf
fi
