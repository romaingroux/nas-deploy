#!/bin/bash
set -eu

# Installs and configures SMB with a shared directory on the RAID array, i.e.
# $1/shared.
# 
# Expects SMB_PASSWORD env variable to be set.
#
# The following is done:
# 1. Create a shared directory at $1/shared
# 2. Sets the shared directory permissions and makes it available to all
#    members of group $3
# 3. Creates a SMB user with password SMB_PASSWORD. This user should be member
#    of group $3
#
# Args:
# $1 the RAID array mount directory
# $2 a user belonging to group $3 to register as SMB user 
# $3 The group that will get access to the SMB share directory.

# RAID array mount point
dir_raid=$1
# SMB shared directory
dir_shared="$dir_raid/shared"
user=$2
# NAS group
nas_group=$3

# user password
password="${SMB_PASSWORD:?SMB_PASSWORD must be set}"

if ! mountpoint -q "$dir_raid"; then
    echo "error, RAID mount point not found: $dir_raid" 1>&2
    exit 1
fi 

if ! getent group "$nas_group" > /dev/null; then
    echo "error, group not found: $nas_group" 1>&2
    exit 1
fi

# shared directory
sudo mkdir "$dir_shared"
sudo chown root:"$nas_group" "$dir_shared"
sudo chmod 2770 "$dir_shared"

# install smb server
sudo apt update -y
sudo apt install -y samba samba-common-bin

# smb service config
# give rights to all nas group users
sudo bash -c "cat >> /etc/samba/smb.conf <<EOF
[shared]
path=$dir_shared
writeable=Yes
create mask = 0660
force create mode = 0660
directory mask = 0770
force directory mode = 0770
public=no
valid users=@$nas_group
EOF"

sudo systemctl restart smb

printf '%s\n%s\n' "$password" "$password" | sudo smbpasswd -s -a "$user"