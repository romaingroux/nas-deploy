# nas-deploy

Shell scripts deploying a small home NAS on a Raspberry Pi: two USB hard
drives in a RAID 1 array, formatted as ext4 and shared on the local network
with Samba. A client script mounts the share on a Linux machine.

## Hardware and OS

The scripts were written for and tested on:

- Raspberry Pi 5 Model B
- Raspberry Pi OS based on Debian 13 (trixie)
- two USB hard drives, visible as `/dev/sda` and `/dev/sdb`, used as the two
  members of the RAID 1 array

## Repository layout

```
scripts/
  server/
    server.sh              entry point, runs the four scripts below in order
    set_wifi_powersave.sh  disables WiFi power saving
    set_users.sh           creates the NAS group and user
    set_raid.sh            builds the RAID 1 array and mounts it
    set_smb.sh             installs Samba and exports the shared directory
  client/
    mount_shared.sh        mounts the share on a Linux client
```

## Warning

`scripts/server/set_raid.sh` **erases both hard drives** without asking.

The scripts are a **one-shot deployment** for a freshly installed Raspberry Pi. They are not meant to be run a second time on the same system.

## Server deployment

On a fresh Raspberry Pi OS installation, with both drives plugged in and a user able to run `sudo`:

```bash
scp -r scripts/server/ <user>@<pi>:~/deploy/
ssh <user>@<pi>
cd ~/deploy/server
./server.sh
```

`server.sh` prompts for the SMB user name, for its password twice, then for the `sudo` password, and runs unattended from there. The RAID array is usable as soon as the script returns, while the initial synchronisation of the two drives continues in the background for several hours. Its progress is shown by `cat /proc/mdstat`.

The result is:

- a RAID 1 array `/dev/md0` on `/dev/sda1` and `/dev/sdb1`, with an ext4 filesystem labelled `nas-raid` mounted at `/mnt/nas-raid`
- a group `nas` and a user, member of that group, registered as a Samba user
- a directory `/mnt/nas-raid/shared` owned by `root:nas` with mode `2770`, exported by Samba as `shared` to the members of group `nas`
- WiFi power saving disabled, which otherwise freezes SSH sessions after a few minutes of inactivity

### What each script does

- `set_wifi_powersave.sh` writes a NetworkManager drop-in disabling WiFi power saving.
- `set_users.sh <group> <user>` creates the group and the user, without home directory, and adds the user to the group.
- `set_raid.sh <mount dir>` installs mdadm, wipes both drives, creates one RAID partition per drive, builds the RAID 1 array, formats it as ext4 and mounts it through `/etc/fstab` by filesystem UUID.
- `set_smb.sh <mount dir> <user> <group>` installs Samba and sets
the `smb` service running with a shared directory on the array.

## Client setup

On a Linux machine on the same network:

```bash
cd scripts/client
./mount_shared.sh
```

The script asks for the Samba user and password, installs `cifs-utils`, sets SMB credentials, and mounts `//raspberrypi-1.local/shared` at `/mnt/nas-shared` through a systemd automount. The share is mounted on first access, e.g. `ls /mnt/nas-shared`.
