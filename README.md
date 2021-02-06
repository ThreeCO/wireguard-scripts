# Wireguard Scripts

add and remove clients from a wireguard server.

`bash add-client.sh <client_name>` will create a config in clients for that client with SPLIT-TUNNEL Configuration.

`bash add-client.sh <client_name> true` will create a config in clients for that client with "TUNNEL-ALL" Configuration.


### This set of scripts was heavily influcenced by:

https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/

https://www.wireguard.com/install/

https://www.wireguard.com/quickstart/


## Installation
NOTE: this assumes some decent commandline knowlege.

1. Clone/fork(if you want to save your own configs) the Repo

1. install wireguard on server (https://www.wireguard.com/install/)

1. install qrencode for easier addition of peers (`apt install qrencode`)

1. as `root`, `cd /etc/wireguard`, and create server keys: `wg genkey | tee server_private_key | wg pubkey > server_public_key`

1. copy `wg0-server.example.conf` in this project to `/etc/wireguard/wg0.conf`

1. edit `/etc/wireguard/wg0.conf` replace `PrivateKey = asdf123=` with the private key created above.
   Change any other settings you need different (ip range, network interfaces[eth0 is outgoing interface in this example])
   stop being root
   
1. add postup and postdown scripts to wg0.conf in order to customize firewall (iptables)
   PostUp=/etc/wireguard/postup.sh
   PostDown=/etc/wireguard/postdown.sh

1. start wireguard: `sudo wg-quick up wg0` 

1. add a client `bash add-client.sh <new-client>`

1. setup iptables rules, see: https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/ step 6 for more details.
    
    have a look at postup.sh and postdown.sh
   
    Make iptables persist: 
    ```
    apt-get install iptables-persistent
    systemctl enable netfilter-persistent
    netfilter-persistent save
    ```

1. if everything is working right: `systemctl enable wg-quick@wg0.service`

1. now lets create our first user

1. now modify variables in `adduser.sh` according to your setup
   ```
   wg_name  = "wg0"
   srv_host = "172.0.0.1"         # external IP of Wireguard
   srv_port = 5280                # external Port of Wireguard
   cl_dns   = "127.0.0.1"         # which DNS-Server shall be used?
   cl_ip    = "10.0.0."           # subnet of client ips; please omit last number
   cl_allowed = "192.10.10.0/32"  # IP for SPLIT-Tunnel / RoadWarrior
   ```
1. add user by typing `bash adduser.sh <name>`

1. (optional) commit your changes to your fork of this repo.


#### Contributing
If you see something wrong and have fixed it, or have something to add, make a Pull Request!




