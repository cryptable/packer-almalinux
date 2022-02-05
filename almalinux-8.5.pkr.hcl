# VM Section
# ----------

variable "vm_name" {
  type    = string
  default = "alma"
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "ram_size" {
  type    = string
  default = "1024"
}

variable "disk_size" {
  type    = string
  default = "10G"
}

variable "iso_checksum" {
  type    = string
  default = "65b3b4c17ce322081e2d743ee420b37b7213f4b14d2ec4f3c4f026d57aa148ec"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

# This is different and configured in the variable templates
variable "eth_point" {
  type    = string
  default = "ens18"
}

# VMware Section
# --------------

variable "iso_url" {
  type    = string
  default = "https://repo.almalinux.org/almalinux/8.5/isos/x86_64/AlmaLinux-8.5-x86_64-boot.iso"
}

variable "output_directory" {
  type    = string
  default = "output-vmware"
}

# Proxmox Section
# ---------------

variable "pve_username" {
  type    = string
  default = "root"
}

variable "pve_token" {
  type    = string
  default = "secret"
}

variable "pve_url" {
  type    = string
  default = "https://127.0.0.1:8006/api2/json"
}

variable "iso_file"  {
  type    = string
  default = "local:iso/AlmaLinux-8.5-x86_64-boot.iso"
}

variable "vm_id" {
  type    = string
  default = "9000"
}

# Alma Linux Section
# ------------------

variable "username" {
  type    = string
  default = "almalinux"  
}

variable "password" {
  type    = string
  default = "AlmaLinux8.5"  
}

variable "sshkey" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFAUvfUcB3XS/KAdk2qO2IkYLDbOEq01inwBRfIiA841JrfC5ukNf284P7SOaReU5LxvLnnYL0h2TsW7uVnOPGxpqg9WUACsTLITLf+j3utm4SYTg25h3RXyruoak15O4XaiGbpr17Fr+q9rBtR9ovvi1DDIvO7qu4hoKGW4SSxa62NpxTmzJlKpcLzeYyaafT8B2C7bCWjESsp7DBHy9cYPyqFP7TcRFR/X/Jm3FY3XF85L0Y2IVvYWgJhYle2ZXcUCZJJR2/zZmBVpPk0BrN3T95WDw9SULduCwMDDOD9+FmSmeQRWk/+kbBrFRP9DpyUmCw8rjhYwcvJIxleVCNBeSlbLXctpI0PvcyUjXHcUWfadAK7D9nn87EUvkvLhdzeC0aiZMUB84Gl+6Cm+yV9XKB2Ah+fabn3IdCkTRis6m0eI882eixsUe3fBd5NARwuJiDlbuaTkyVmAuAv9nMBy9bdne+xxIA4AHyZ5rddccHBfg5k7TBBz8dPyIa8S0="
}

variable "hostname" {
  type    = string
  default = "alma"
}

# Vagrant Section
# ---------------

variable "vagrant_token" {
  type    = string
  default = "<Atlas token>"
}

variable "vagrant_version" {
  type    = string
  default = "0.0.0"
}

# VMWARE image section
# --------------------

source "vmware-iso" "almalinux" {
  boot_command         = [
    "<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux.ks<enter><wait>"
  ]
  boot_wait            = "10s"
  communicator         = "ssh"
  cpus                 = "${var.cpu}"
  disk_size            = "${var.disk_size}"
  http_directory       = "./http/vmware/linux/alma/8.5"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.ram_size}"
  shutdown_command     = "echo '${var.password}' | sudo -S -E shutdown -P now"
  ssh_timeout          = "10m"
  ssh_username         = "${var.username}"
  ssh_password         = "${var.password}"
  vm_name              = "${var.vm_name}"
  guest_os_type        = "centos-64"
  output_directory     = "${var.output_directory}"
  format = "ova"
}

# Proxmox image section
# ---------------------

source "proxmox-iso" "almalinux" {
  proxmox_url = "${var.pve_url}"
  username = "${var.pve_username}"
  token = "${var.pve_token}"
  node =  "pve"
  iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_file = "${var.iso_file}"
  insecure_skip_tls_verify = true
  boot_command         = [
    "<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux.ks<enter><wait>"
  ]
  boot_wait            = "10s"
  communicator         = "ssh"
  cores                = "${var.cpu}"
  http_directory       = "./http/proxmox/linux/alma/8.5"
  memory               = "${var.ram_size}"
  ssh_timeout          = "30m"
  ssh_username         = "${var.username}"
  ssh_password         = "${var.password}"
  vm_name              = "${var.vm_name}"
  vm_id                = "${var.vm_id}"
  os        = "l26"
  network_adapters {
    model = "e1000"
    bridge = "vmbr0"
  }
  scsi_controller = "virtio-scsi-pci"
  disks {
    type = "scsi"
    disk_size  = "${var.disk_size}"
    storage_pool = "local-lvm"
    storage_pool_type = "lvm-thin"
    format = "raw"
  }
  template_name = "almalinux85"
  template_description = "Alma Linux 8.5 template to build Alma Linux server"
}

source "null" "vagrant" {
  communicator = "none"
}

build {
  sources = [
    "source.proxmox-iso.almalinux",
    "source.vmware-iso.almalinux",
    "source.null.vagrant"
  ]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh {{ .Path }}"
    environment_vars = [
      "USERNAME=${var.username}",
      "SSHKEY=${var.sshkey}"
    ]
    scripts         = [
      "./scripts/update.sh", 
      "./scripts/ssh-config.sh",
      "./scripts/cleanup.sh",
      "./scripts/harden.sh",
    ]
    only = [ 
      "vmware-iso.almalinux", 
      "proxmox-iso.almalinux" 
    ]
  }

  post-processors {  
    post-processor "artifice" {
      files = [
        "output-vmware/disk-s001.vmdk",
        "output-vmware/disk-s002.vmdk",
        "output-vmware/disk-s003.vmdk",
        "output-vmware/disk.vmdk",
        "output-vmware/alma-template.nvram",
        "output-vmware/alma-template.vmsd",
        "output-vmware/alma-template.vmx",
        "output-vmware/alma-template.vmxf"
      ]
      only = [ 
        "vmware-iso.almalinux", 
        "null.vagrant" 
      ]
    }
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "vmware"
      output = "output-vmware/packer_alma_vmware.box"
      only = [ 
        "vmware-iso.almalinux", 
        "null.vagrant" 
      ]
    }
  }
  post-processors {  
    post-processor "artifice" {
      files = [
        "output-vmware/packer_alma_vmware.box"
      ]
      only = [ 
        "null.vagrant"
      ]
    }
    post-processor "vagrant-cloud" {
      access_token = "${var.vagrant_token}"
      box_tag      = "cryptable/alma85"
      version      = "${var.vagrant_version}"
      version_description = "Empty Alma Linux"
      only = [ 
        "null.vagrant"
      ]
    }
  } 
}
