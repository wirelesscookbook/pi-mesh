#!/bin/bash
#
# Raspberry Pi mesh gateway node startup script
# Author: @billz <billzimmerman@gmail.com>
# Author URI: https://github.com/billz/
# License: GNU General Public License v3.0
# License URI: https://github.com/wificookbook/pi-mesh/blob/master/LICENSE

iface=${1:-wlan1}
networkid="pi-mesh"

echo "Configuring ${iface} as mesh point..."

# get physical address of wlan1 adapter
addr=$(iw dev ${iface} info | awk '$1=="wiphy"{print $2}')
echo "Physical ${iface} address is phy#${addr}"

# load the module
echo "Loading batman-adv kernel module"
sudo modprobe batman-adv

# configure interface as mesh node
echo "Releasing ${iface} interface"
sudo iw dev ${iface} del

# wait for interface to be released properly
sleep 2

# add wlan1 interface of type 'mesh'
echo "Adding ${iface} as mesh interface"
sudo iw phy phy${addr} interface add ${iface} type mesh

# set MTU value for interface and join pi-mesh
echo "Setting MTU value for batman-adv and joining ${networkid}"
sudo ip link set up mtu 1532 dev ${iface}
sudo iw dev ${iface} mesh join ${networkid}
sleep 1

# tell batman-adv this is a gateway node
sudo batctl gw_mode server

# Enable port forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o bat0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i bat0 -o eth0 -j ACCEPT

# tell batman-adv to create the bat0 mesh interface
echo "Adding ${iface} to batman-adv and bringing it up"
sudo batctl if add ${iface}
sudo ip link set up dev bat0

echo "Diagnostic output from batctl..."
sudo batctl if
sleep 2
sudo batctl n
