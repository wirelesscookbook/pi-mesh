# Raspberry Pi mesh node network activity script
# Author: @billz <billzimmerman@gmail.com>
# Author URI: https://github.com/billz/
# License: GNU General Public License v3.0
# License URI: https://github.com/wirelesscookbook/pi-mesh/blob/master/LICENSE

from gpiozero import StatusZero
from time import sleep
import psutil
import time
import sys

sz = StatusZero('send', 'receive')
# Default network interface
interface = 'wlan1'

# Check if the interface is provided as a command-line argument
if len(sys.argv) > 1:
    interface = sys.argv[1]

print(f"Monitoring interface: {interface}")

# Variables to track previous network activity
previous_sent = 0
previous_recv = 0

def flash_send():
    sz.send.on()
    time.sleep(0.01)
    sz.send.off()

def flash_recv():
    sz.receive.on()
    time.sleep(0.01)
    sz.receive.off()

try:
    while True:
        net_io = psutil.net_io_counters(pernic=True)
        interface_io = net_io.get(interface)

        if interface_io:
            # Check for network activity
            current_sent = interface_io.bytes_sent
            current_recv = interface_io.bytes_recv

            if current_sent != previous_sent:
                flash_send()

            if current_recv != previous_recv:
                flash_recv()

            previous_sent = current_sent
            previous_recv = current_recv

        time.sleep(0.01)  # Adjust the sleep time as needed

except KeyboardInterrupt:
    print("Exiting gracefully")

