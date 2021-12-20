#!/bin/bash
#
# Raspberry Pi mesh network startup script
# Author: @billz <billzimmerman@gmail.com>
# Author URI: https://github.com/billz/
# License: GNU General Public License v3.0
# License URI: https://github.com/wificookbook/pi-mesh/blob/master/LICENSE

# re-configure interface as mesh node 
sudo iw dev wlan1 del
sudo iw phy phy1 interface add wlan1 type mesh

# set MTU value for interface and join pi-mesh
sudo ip link set up mtu 1532 dev wlan1
sudo iw dev wlan1 mesh join pi-mesh

# instruct batman-adv to create the bat0 mesh interface
sudo batctl if add wlan1
sudo ip link set up dev bat0

# assign an IPv4 address to bat0
sudo ip addr add 192.168.0.1/24 dev bat0

