variable "pm_password" {
    description = "Proxmox root password"
    type        = string
    sensitive   = true
}

variable "vms" {
    description = "List of VM to create"
    type = list(object({
        name = string
        vmid = number
        ip = string
    }))
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2E... your-public-key-here"
}

variable "env_user" {
    default = "ubuntu"
}

variable "env_pass" {
    default = "ubuntu"
}