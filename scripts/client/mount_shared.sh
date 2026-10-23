#!/bin/bash
set -eu

# Sets and mounts the NAS shared directory on the local machine at 
# /mnt/nas-shared.
# 
# The following is done:
# 1. Mounts the NAS shared drive at /mnt/nas-shared
# 2. Sets the credencial for the shared drive access. The username and 
#    password will be demanded. These must be a valid existing SMB user.

user=""
password=""
shared="//raspberrypi-1.local/shared"
mountpoint="/mnt/nas-shared"
credentials="/root/.smbcredentials"

read -r -p "SMB user: " user
read -r -s -p "SMB password for user ${user}: " password
echo

sudo apt install -y cifs-utils
sudo mkdir -p ${mountpoint}

printf 'username=%s\npassword=%s\n' "$user" "$password" | sudo tee ${credentials} >/dev/null
sudo chmod 600 ${credentials}

if ! grep -q " ${mountpoint} " /etc/fstab; then
    echo "${shared} ${mountpoint} cifs credentials=${credentials},uid=1000,gid=1000,file_mode=0660,dir_mode=0770,vers=3.0,nofail,_netdev,x-systemd.automount 0 0" | sudo tee -a /etc/fstab >/dev/null
fi

sudo systemctl daemon-reload
