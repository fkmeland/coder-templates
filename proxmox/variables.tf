variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL"
  default     = "https://your-proxmox-server:8006/api2/json"
}

variable "proxmox_api_insecure" {
  type        = string
  description = "Allow insecure HTTPS connections to the Proxmox API (true/false)"
  default     = "true"
  validation {
    condition     = contains(["true", "false"], var.proxmox_api_insecure)
    error_message = "proxmox_api_insecure must be either 'true' or 'false'."
  }
}

variable "proxmox_api_auth_method" {
  type        = string
  description = "Authentication method: 'username_password' or 'token'"
  default     = ""
  validation {
    condition     = contains(["username_password", "token"], var.proxmox_api_auth_method)
    error_message = "proxmox_api_auth_method must be either 'username_password' or 'token'."
  }
}

variable "proxmox_api_username" {
  type        = string
  description = "Proxmox username (e.g., 'root@pam')"
  default     = ""
}

variable "proxmox_api_password" {
  type        = string
  sensitive   = true
  description = "Proxmox password"
  default     = ""
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token ID (e.g., 'root@pam!mytoken')"
  default     = ""
}

variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Proxmox API token secret"
  default     = ""
}



variable "proxmox_default_vm_target_node" {
  type        = string
  description = "Default Proxmox node name to pre-fill in the node selection field"
  default     = "pve01"
}

variable "proxmox_template_storage" {
  type        = string
  description = "Storage location for the template (e.g., 'local' for QEMU or 'local:vztmpl' for LXC)"
  default     = "local:vztmpl"
}

variable "proxmox_template_name" {
  type        = string
  description = "Name of the template to use (without storage prefix)"
  default     = "coder-workspace_24.04.tar.gz"
}

variable "proxmox_use_lxc" {
  type        = bool
  description = "Use LXC container instead of QEMU VM"
  default     = true
}

variable "container_disk_size" {
  type        = number
  description = "Disk size for the container in GB"
  default     = 10
  validation {
    condition     = var.container_disk_size >= 5 && var.container_disk_size <= 100
    error_message = "The container_disk_size must be between 5 and 100 GB."
  }
}

variable "container_cpu_cores" {
  type        = number
  description = "Number of CPU cores for the container"
  default     = 2
  validation {
    condition     = var.container_cpu_cores >= 1 && var.container_cpu_cores <= 8
    error_message = "The container_cpu_cores must be between 1 and 8."
  }
}

variable "container_memory" {
  type        = number
  description = "Memory allocation for the container in MB"
  default     = 2048
  validation {
    condition     = contains(["1024", "2048", "3072", "4096", "6144"], tostring(var.container_memory))
    error_message = "The container_memory must be one of 1024, 2048, 3072, 4096, or 6144 MB."
  }
}

variable "git_committer_email" {
  type        = string
  description = "Email address for Git commits"
  default     = "coder@coder.com"
}

variable "container_ssh_username" {
  description = "Username for SSH access"
  type        = string
  default     = "coder"
}

variable "container_ssh_password" {
  description = "Password for SSH access"
  type        = string
  sensitive   = true
  default     = "coder"
}
