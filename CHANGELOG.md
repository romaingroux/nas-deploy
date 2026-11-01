# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Server deployment scripts for a Raspberry Pi NAS: `scripts/server/server.sh`
  orchestrates the creation of the NAS group and user, the WiFi power-save
  configuration, the RAID 1 array on the two USB disks, and the Samba share.
- Client script `scripts/client/mount_shared.sh` mounting the Samba share on a Linux
  machine through `fstab` with a systemd automount.
