#!/bin/bash
set -eu

# Sets HDDs on Raspberry Pi as a ext4 RAID 1 array (/dev/md0) and mounts
# them at $1.
# WARNING: this script formats hardrives and LEADING TO PERMANENT DATA LOSSES
#
# Args:
# $1 the RAID array mount directory

sudo apt install -y mdadm

# HDDs
dev_hdd_1="/dev/sda"
dev_hdd_2="/dev/sdb"
# RAID device
dev_raid="/dev/md0"
# RAID mount dir
dir_mount=$1

# erase leftover RAID superblocks in partitions, otherwise mdadm --create
# fails with "Device or resource busy"
sudo mdadm --stop --scan
for part in "${dev_hdd_1}1" "${dev_hdd_2}1"; do
    [ -e "$part" ] && sudo mdadm --zero-superblock --force "$part"
done
# erase HDDs
sudo wipefs -a "$dev_hdd_1" "$dev_hdd_2"

# partition
sudo parted -s $dev_hdd_1 mklabel gpt mkpart primary 1MiB 100% set 1 raid on
sudo parted -s $dev_hdd_2 mklabel gpt mkpart primary 1MiB 100% set 1 raid on

# set RAID 1 array
sudo mdadm --create --verbose $dev_raid --level=1 --raid-devices=2 --bitmap=internal --run ${dev_hdd_1}1 ${dev_hdd_2}1

# format array
sudo mkfs.ext4 -F -L nas-raid $dev_raid
# persist array as $dev_raid, dropping any ARRAY line left from a previous install
sudo sed -i '/^ARRAY/d' /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u

# mount
sudo udevadm settle
dev_raid_uuid=$(sudo blkid -s UUID -o value "$dev_raid")
sudo sh -c " echo \"UUID=$dev_raid_uuid  $dir_mount  ext4  defaults,noatime,nofail  0  2\" >> /etc/fstab"
sudo systemctl daemon-reload
sudo mkdir -p $dir_mount
sudo mount -a
