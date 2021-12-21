#!/bin/bash
#
# Raspberry Pi mesh network startup script
# Author: @billz <billzimmerman@gmail.com>
# Author URI: https://github.com/billz/
# License: GNU General Public License v3.0
# License URI: https://github.com/wificookbook/pi-mesh/blob/master/LICENSE

iface=$1

echo "Configuring ${iface} as mesh point..."

# get physical address of wlan1 adapter
addr=$(iw dev ${iface} info | awk '$1=="wiphy"{print $2}')
echo "physical ${iface} address is phy#${addr}"

# load the module
echo "Loading batman-adv kernel module"
modprobe batman-adv

# configure interface as mesh node
echo "Releasing ${iface} interface"
sudo iw dev ${iface} del

# wait for interface to be released properly
sleep 2

# add wlan1 interface of type 'mesh'
echo "Adding ${iface} as mesh interface"
sudo iw phy phy${addr} interface add ${iface} type mesh

# set MTU value for interface and join pi-mesh
echo "Setting MTU value for batman-adv and joining pi-mesh"
sudo ip link set up mtu 1532 dev ${iface}
sudo iw dev ${iface} mesh join pi-mesh

# instruct batman-adv to create the bat0 mesh interface
echo "Adding ${iface} to batman-adv and bringing it up"
sudo batctl if add ${iface}
sudo ip link set up dev bat0

# assign an IPv4 address to bat0
echo "Assigning IPv4 address to bat0"
sudo ip addr add 192.168.0.2/24 dev bat0

echo "Diagnostic output from batctl..."
sudo batctl if
sleep 1
sudo batctl n
