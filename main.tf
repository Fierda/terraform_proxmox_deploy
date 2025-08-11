terraform {
    required_providers {
        proxmox = {
            source = "Telmate/proxmox"
            version = "3.0.2-rc03"
        }
    }
    required_version = ">= 1.3.0"
}

provider "proxmox" {
    pm_api_url = "https://192.168.215.122:8006/api2/json"
    pm_user = "root@pam"
    pm_password = var.pm_password
    pm_tls_insecure = true
}

resource "local_file" "cloudinits" {
    for_each = { for vm in var.vms : vm.name => vm }
    content = templatefile("${path.module}/cloud_init.tpl",{
        hostname = each.value.name
        env_user = var.env_user
        env_pass = var.env_pass
        hashed_pass = bcrypt(var.env_pass)


    })
    filename = "${path.module}/snippets/${each.value.name}--cloudinit.yml"
    file_permission     = "0640"
    directory_permission = "0755"
}

resource "proxmox_vm_qemu" "vms" {
    for_each = { for vm in var.vms : vm.name => vm }
    name = each.value.name
    vmid = each.value.vmid
    target_node = "proxmox"
    
    # Fix deprecated cores argument
    cpu {
        cores = 4
    }
    
    memory = 16384
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    
    # Main disk - fix slot format and type
    disk {
        slot    = "scsi0"
        size    = "32G"
        type    = "disk"
        storage = "local-lvm"
    }
    
    # CD-ROM disk - fix slot format and type
    disk {
        slot    = "ide2"
        type    = "cdrom"
        storage = "local:iso/ubuntu-24.04-live-server-amd64.iso"
    }
    
    network {
        id     = 0
        model  = "virtio"
        bridge = "vmbr0"
    }
    
    os_type = "cloud-init"
    
    # Cloud-init configuration
    ciuser     = var.env_user
    cipassword = var.env_pass
    ipconfig0  = "ip=${each.value.ip},gw=147.234.234.1"
    sshkeys    = var.ssh_public_key
    cicustom   = "user=local:snippets/${each.value.name}-cloudinit.yml"
}