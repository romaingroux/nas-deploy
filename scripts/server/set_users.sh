#!/bin/bash
set -eu

# Create NAS dedicated group ($1) and adds the given user ($2) inside
#
# Args:
# $1 the NAS dedicated group name
# $2 the user to add in the NAS dedicated group 

nas_group=$1
user=$2

sudo groupadd $nas_group
sudo useradd ${user} --no-create-home --groups $nas_group