#!/bin/bash
set -e

source ./image-configs/$1-$2.shvars
sh ./scripts/prep-kickstart-$2-iso.sh

if [ $2 == "vmware" ]; then 
  packer build -on-error=ask -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var sshkey='${SSHKEY}' -var-file=./image-configs/$1-$2.pkrvars.hcl -only=vmware-iso.almalinux .
fi

if [ $2 == "proxmox" ]; then
  packer build -on-error=ask -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var sshkey='${SSHKEY}' -var vagrant_token=${VAGRANT_TOKEN} -var-file=./image-configs/$1-$2.pkrvars.hcl -only=proxmox-iso.almalinux .
fi

if [ $2 == "vagrant" ]; then
  if [ ! -f "./output-vmware/packer_alma_vmware.box" ]; then
      packer build -on-error=ask -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var sshkey='${SSHKEY}' -var-file=./image-configs/$1-$2.pkrvars.hcl -only=vmware-iso.almalinux .
  fi
  ./update-version.sh
  source ./VERSION
  echo ${VERSION}
  packer build -on-error=ask -var vagrant_version=${VERSION} -var-file=./image-configs/$1-$2.pkrvars.hcl -only=null.vagrant .
fi