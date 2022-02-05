#!/bin/bash
set -e

source ./image-configs/$1-$2.shvars
sh ./scripts/prep-kickstart-$2-iso.sh

packer build -on-error=ask -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var sshkey='${SSHKEY}' -var-file=./image-configs/$1-$2.pkrvars.hcl .