#!/bin/bash
set -e

# a system user for SMB shared drive that will also be a SMB user
user=""
password=""
# the NAS dedicated group for SMB shared access
nas_group="nas"
# the path to the directory where the RAID array will be moutned
dir_raid="/mnt/nas-raid"

read -r -p "enter a SMB user: " user
read -r -s -p "enter password for user ${user}: " password
echo
read -r -s -p "confirm password for user ${user}: " password_confirm
echo
if [ "$password" != "$password_confirm" ]; then
    echo "error, passwords do not match" 1>&2
    exit 1
fi

echo "$(date) [server.sh] setting WiFi power saving..."
./set_wifi_powersave.sh
echo "$(date) [server.sh] setting WiFi power saving done"

# create users and groups
echo "$(date) [server.sh] setting users..."
./set_users.sh "$nas_group" "$user"
echo "[server.sh] setting users done"

# set up RAID
echo "$(date) [server.sh] setting RAID..."
./set_raid.sh "$dir_raid"
echo "$(date) [server.sh] setting RAID done"

# set SMB server
export SMB_PASSWORD="$password"
echo "$(date) [server.sh] setting SMB..."
./set_smb.sh "$dir_raid" "$user" "$nas_group"
echo "$(date) [server.sh] setting SMB done"
