WIREGUARD_INTERFACE="wg0"
WIREGUARD_LAN="10.0.0.0/24"
WIREGUARD_PORT=5280
MASQUERADE_INTERFACE="eth0"

sudo iptables -t nat -D POSTROUTING -o $MASQUERADE_INTERFACE -j MASQUERADE -s 10.0.0.0/24

# Add a WIREGUARD_wg0 chain to the FORWARD chain
CHAIN_NAME="WIREGUARD_$WIREGUARD_INTERFACE"

# Remove and delete the WIREGUARD_wg0 chain
sudo iptables -D FORWARD -j $CHAIN_NAME
sudo iptables -F $CHAIN_NAME
sudo iptables -X $CHAIN_NAME

# Remove WG-Port
sudo iptables -D UDP -p udp --dport $WIREGUARD_PORT -j ACCEPT
