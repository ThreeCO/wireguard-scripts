WIREGUARD_INTERFACE=wg0
WIREGUARD_LAN=10.0.0.0/24
MASQUERADE_INTERFACE=eth0

# Add MASQUERADE-RULE
sudo iptables -t nat -I POSTROUTING -o $MASQUERADE_INTERFACE -j MASQUERADE -s $WIREGUARD_LAN

#Add a WIREGUARD_wg0 chain to the FORWARD chain
CHAIN_NAME="WIREGUARD_$WIREGUARD_INTERFACE"
sudo iptables -N $CHAIN_NAME
sudo iptables -A FORWARD -j $CHAIN_NAME

# Accept related
sudo iptables -A $CHAIN_NAME -o $WIREGUARD_INTERFACE -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# jump to TCP/UPD Blacklists
sudo iptables -A $CHAIN_NAME -s 10.0.0.0/24 -i $WIREGUARD_INTERFACE -p tcp -j FW_WG_TCP
sudo iptables -A $CHAIN_NAME -s 10.0.0.0/24 -i $WIREGUARD_INTERFACE -p udp -j FW_WG_UDP

# Accept traffic from any Wireguard IP address connected to the Wireguard server
sudo iptables -A $CHAIN_NAME -s 10.0.0.0/24 -i $WIREGUARD_INTERFACE -j ACCEPT

# deny with icmp-message
sudo iptables -A $CHAIN_NAME -i $WIREGUARD_INTERFACE -j REJECT --reject-with icmp-host-unreachable

# Drop everything else coming through the Wireguard interface
sudo iptables -A $CHAIN_NAME -i $WIREGUARD_INTERFACE -j DROP

# Return to FORWARD chain
sudo iptables -A $CHAIN_NAME -j RETURN

# ADD WG-Port to INPUT chain
sudo iptables -A UDP -p udp --dport 5280 -j ACCEPT

