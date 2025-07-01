# Raspberry Pi mesh node network activity script.
# Adapated for the Squid RGB.
#
# Credit to @simonmonk for the squid.py library.
# @see https://monkmakes.com/squid-single
#
# Author: @billz <billzimmerman@gmail.com>
# Author URI: https://github.com/billz/
# License: GNU General Public License v3.0
# License URI: https://github.com/wirelesscookbook/pi-mesh/blob/master/LICENSE

from squid import Squid, RED, GREEN, OFF
from time import sleep
import psutil
import time
import sys

# GPIO pins for RED, GREEN, BLUE channels (BCM numbering)
RED_PIN = 17
GREEN_PIN = 27
BLUE_PIN = 22

led = Squid(RED_PIN, GREEN_PIN, BLUE_PIN)

# Default network interface
interface = 'wlan1'

# Check if interface is passed as an argument
if len(sys.argv) > 1:
    interface = sys.argv[1]

print(f"Monitoring interface: {interface}")

# Track previous byte counts
previous_sent = 0
previous_recv = 0

def flash(color):
    # print("flash LED: ", color) # Uncomment to display LED flash in the console
    led.set_color(color)
    time.sleep(0.01)  # Flash duration
    led.set_color(OFF)

try:
    while True:
        net_io = psutil.net_io_counters(pernic=True)
        interface_io = net_io.get(interface)

        if interface_io:
            current_sent = interface_io.bytes_sent
            current_recv = interface_io.bytes_recv

            if current_sent != previous_sent:
                flash(GREEN)

            if current_recv != previous_recv:
                flash(RED)

            previous_sent = current_sent
            previous_recv = current_recv

        # time.sleep(0.01) # Adjust the sleep time if desired

except KeyboardInterrupt:
    print("Exiting gracefully")
    led.set_color(OFF)

