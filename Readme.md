EJBCA Packer template
=====================

Introduction
------------

This is a Hashicorp packer file to build an Alma Linux template for VMWare and Proxmox.

Setup
-----

1) Verify the template variables in the image-configs directory. Create a copy from the templates to your technology.

You can build them using command:
```
./build.sh <domain> <proxmox|vmware|vagrant>
```

It will concatenate to the template in the image-configs directory:

- <domain>-<vm-technology>.shvars : settings to create the cloud-init user-date file
- <domain>-<vm-technology>.pkrvars.hcl: settings to build the images

Vagrant will try to deploy on the Vagrant Cloud.

DANGER: 
Don't use the default .shvars-file, because it is just an example. It is better to reconfigure the file or use a Vault system to retrieve the credentials.
The SSH key is a dummy key and usable for you.

TODO
----


Notes
-----
