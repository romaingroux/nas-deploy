#!/bin/bash
set -eu

# disable WiFi power save, SSH sessions may freeze after a few minutes of 
# inactivity without this

sudo sh -c "echo \"[connection]\nwifi.powersave = 2\" > /etc/NetworkManager/conf.d/wifi-powersave-off.conf"