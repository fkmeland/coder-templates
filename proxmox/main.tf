# ---------------------------------------------------------------------------------------------------------------------
# Terraform Configuration and Providers
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "~> 2.0"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}


provider "coder" {}

provider "proxmox" {
  pm_api_url      = var.proxmox_url
  pm_tls_insecure = var.proxmox_api_insecure == "true"

  # Use conditional expressions to set the appropriate authentication method
  pm_api_token_id     = var.proxmox_api_auth_method == "token" && var.proxmox_api_token_id != "" ? var.proxmox_api_token_id : null
  pm_api_token_secret = var.proxmox_api_auth_method == "token" && var.proxmox_api_token_secret != "" ? var.proxmox_api_token_secret : null

  pm_user     = var.proxmox_api_auth_method == "username_password" && var.proxmox_api_username != "" ? var.proxmox_api_username : null
  pm_password = var.proxmox_api_auth_method == "username_password" && var.proxmox_api_password != "" ? var.proxmox_api_password : null
}

# ---------------------------------------------------------------------------------------------------------------------
# Proxmox Cluster Node Options
# ---------------------------------------------------------------------------------------------------------------------
# Static list of common Proxmox node names - users can customize this list
# by modifying the proxmox_cluster_nodes variable
locals {
  # Use the node name directly from the text input
  selected_node = data.coder_parameter.proxmox_target_node.value
}

# ---------------------------------------------------------------------------------------------------------------------
# Coder Data Sources
# ---------------------------------------------------------------------------------------------------------------------
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}
data "coder_provisioner" "me" {}

data "coder_parameter" "proxmox_target_node" {
  name         = "proxmox_target_node"
  display_name = "Proxmox Target Node"
  description  = "Enter the Proxmox cluster node name (e.g., pve01, pve02, pve03)"
  type         = "string"
  icon         = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbDpzcGFjZT0icHJlc2VydmUiIHZpZXdCb3g9IjAgMzQgNTEyIDQ0NCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTEzNy45IDM0LjFjLTEwLjUgMC0xOS43IDEuOS0yOC41IDUuNy04LjYgMy44LTE2LjIgOC45LTIyLjkgMTUuNmwxNzAgMTg2LjRMNDI2LjEgNTUuM2MtNi43LTYuNy0xNC4zLTExLjgtMjMuNC0xNS42LTguMy0zLjgtMTgtNS43LTI4LTUuNy0xMC41IDAtMjAuNSAyLjItMjkuNCA2LjItOS4yIDQtMTYuNyAxMC0yMy43IDE3bC02NS4yIDcyLjItNjYtNzIuMmMtNi43LTctMTQuMy0xMi45LTIzLjctMTctOC4zLTQtMTguMy02LjEtMjguOC02LjFNMjU2LjQgMjcwbC0xNzAgMTg2LjdjNi43IDYuNSAxNC4zIDExLjggMjIuOSAxNS42IDguOSAzLjggMTguMSA1LjcgMjggNS43IDExIDAgMjAuNS0yLjQgMjkuNC02LjIgOS40LTQuMyAxNy41LTEwIDI0LjItMTdsNjUuNS03Mi4yIDY1LjQgNzIuMmM2LjcgNyAxNC4zIDEyLjcgMjMuNCAxNyA4LjkgMy44IDE4LjYgNi4yIDI5LjQgNi4yIDEwIDAgMTkuNy0xLjkgMjgtNS43IDkuMi0zLjggMTYuNy05LjIgMjMuNC0xNS42eiIgc3R5bGU9ImZpbGwtcnVsZTpldmVub2RkO2NsaXAtcnVsZTpldmVub2RkIi8+PHBhdGggZD0iTTU2IDkwLjFjLTEwLjguMy0yMS4zIDIuNC0zMC43IDYuNS05LjcgNC0xOCA5LjctMjUuMyAxNi43TDEyOS44IDI1NiAwIDM5OC41YzcuMyA3LjMgMTUuNiAxMi45IDI1LjMgMTcuMiA5LjQgNC4zIDE5LjkgNi4yIDMwLjcgNi43IDExLjYtLjUgMjIuNC0yLjQgMzIuMy03LjNxMTUtNi45IDI1LjgtMTguNmwxMjgtMTQwLjUtMTI3LjktMTQwLjNjLTcuOC03LjUtMTYuMi0xMy43LTI2LjEtMTguNi0xMC00LjYtMjAuNS02LjctMzIuMS03bTM5OS43IDBjLTExLjYuMy0yMS44IDIuNC0zMS44IDctMTAgNC44LTE4LjYgMTEtMjYuMSAxOC42TDI3MC40IDI1NmwxMjcuNCAxNDAuNnExMS4yNSAxMS43IDI2LjEgMTguNmMxMCA0LjggMjAuMiA2LjcgMzEuOCA3LjMgMTEuNi0uNSAyMS41LTIuNCAzMS02LjcgMTAuMi00LjMgMTgtMTAgMjUuMy0xNy4yTDM4Mi41IDI1NiA1MTIgMTEzLjNjLTcuMy03LTE1LjEtMTIuNy0yNS4zLTE2LjctOS40LTQuMS0xOS40LTYuMi0zMS02LjUiIHN0eWxlPSJmaWxsLXJ1bGU6ZXZlbm9kZDtjbGlwLXJ1bGU6ZXZlbm9kZDtmaWxsOiNlNTcwMDAiLz48L3N2Zz4="
  mutable      = false
  default      = var.proxmox_default_vm_target_node
}

data "coder_parameter" "proxmox_disk_size" {
  name    = "Workspace Disk Size (GB)"
  type    = "number"
  default = var.container_disk_size
}

data "coder_parameter" "proxmox_cpu_cores" {
  name    = "Workspace CPU Cores"
  type    = "number"
  default = var.container_cpu_cores
}

data "coder_parameter" "proxmox_memory" {
  name    = "Workspace Memory (MB)"
  type    = "number"
  icon    = "/icon/memory.svg"
  default = var.container_memory
}

data "coder_parameter" "golang_version" {
  name         = "golang_version"
  display_name = "Go Version"
  description  = "Go version to install ('latest', specific version like '1.21.0', or 'none' to disable)"
  type         = "string"
  default      = "latest"
  mutable      = true
  icon         = "/icon/go.svg"
}



data "coder_parameter" "nvm_version" {
  name         = "nvm_version"
  display_name = "NVM Version"
  description  = "Which version of NVM would you like to use?"
  type         = "string"
  default      = "latest"
  mutable      = true
  icon         = "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48c3ZnIGlkPSJhIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1OTUuMjggMjg1LjA2Ij48ZGVmcz48c3R5bGU+LmJ7c3Ryb2tlOiNmZmY7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDoycHg7fS5iLC5jLC5ke2ZpbGw6I2ZmZjt9LmIsLmQsLmV7ZmlsbC1ydWxlOmV2ZW5vZGQ7fTwvc3R5bGU+PC9kZWZzPjxwYXRoIGNsYXNzPSJjIiBkPSJNNTYzLjE2LDE0MS4xYzAsMTYuMjEsLjAyLDMyLjQzLDAsNDguNjQtLjAxLDYuNjUtMi4zMyw3Ljk1LTguMTQsNC42NC0xMS42MS02LjYxLTIzLjE3LTEzLjMyLTM0Ljg1LTE5LjgxLTQuMi0yLjMzLTYuMDktNS40Mi02LjAxLTEwLjMyLC4yMi0xNC4yNi0uMDItMjguNTMsLjEzLTQyLjgsLjA1LTUuMS0xLjc2LTguNjMtNi4zNy0xMS00LjYxLTIuMzctOS4wNi01LjA3LTEzLjUxLTcuNzItMy4zMy0xLjk5LTYuNTctMi4xLTkuOTMtLjE0LTUuMDUsMi45NC0xMC4xMSw1Ljg0LTE1LjE4LDguNzQtMi45NSwxLjY5LTQuMzIsNC4wMi00LjMxLDcuNiwuMDcsMjMuNDgtLjAzLDQ2Ljk1LS4wOSw3MC40My0uMDIsNy4xOC0yLjIyLDguNDMtOC41MSw0Ljg0LTExLjQ5LTYuNTYtMjIuOTMtMTMuMjEtMzQuNS0xOS42NC00LjIxLTIuMzQtNi4wOC01LjQzLTYtMTAuMzIsLjIyLTE0LjI2LS4wMi0yOC41MywuMTMtNDIuOCwuMDUtNS4xLTEuNzgtOC42My02LjM4LTEwLjk5LTQuNS0yLjMtOC44Ni00Ljg5LTEzLjE3LTcuNTQtMy43NC0yLjMtNy4yNC0yLjIxLTEwLjk1LC4wNi00LjMxLDIuNjQtOC42OCw1LjIyLTEzLjE3LDcuNTUtNC40MiwyLjMtNi4zMSw1LjY2LTYuMjUsMTAuNjUsLjE2LDE0LjUzLS4wNCwyOS4wNSwuMTIsNDMuNTgsLjA1LDQuNDEtMS42Myw3LjMxLTUuNDMsOS40NS0xMi4xLDYuOC0yNC4xMSwxMy43Ny0zNi4xNywyMC42My00Ljc4LDIuNzItNy40LDEuMjEtNy40MS00LjM0LS4wNi0zMi45NC0uMDYtNjUuODktLjE0LTk4LjgzLDAtNC4wMywxLjU4LTYuODgsNS4xMS04Ljg5LDIxLjI5LTEyLjE2LDQyLjU2LTI0LjM2LDYzLjgtMzYuNiwzLjUxLTIuMDIsNi43Ni0xLjk3LDEwLjI2LC4wNiwxMy43LDcuOTMsMjcuNDgsMTUuNzEsNDEuMTYsMjMuNjgsMi4wOCwxLjIxLDMuNTQsMS4yLDUuNjEsMCwxMy4zMy03Ljc5LDI2LjgtMTUuMzMsNDAuMS0yMy4xNiw0LjI4LTIuNTIsOC4wNC0yLjU2LDEyLjM2LS4wNSwyMC42NCwxMiw0MS4zNSwyMy44Nyw2Mi4xLDM1LjY1LDQuMDksMi4zMiw1LjgyLDUuNDgsNS43OSwxMC4xMS0uMTEsMTYuMjEtLjA0LDMyLjQzLS4wNCw0OC42NGgtLjE0WiIvPjxwYXRoIGNsYXNzPSJjIiBkPSJNMzAuNDcsMTQwLjhjMC0xNS45NSwuMTEtMzEuOS0uMDctNDcuODUtLjA2LTQuOTcsMS43LTguMjQsNi4wNy0xMC43MiwyMC44OC0xMS44Myw0MS42OC0yMy44LDYyLjQ0LTM1LjgzLDMuNzgtMi4xOSw3LjEyLTIuMjcsMTAuOTItLjA3LDIwLjg3LDEyLjEsNDEuNzksMjQuMTMsNjIuNzcsMzYuMDQsNC4wOCwyLjMyLDUuODgsNS40Miw1Ljg2LDEwLjA2LS4xMiwzMi40Mi0uMTIsNjQuODQtLjE5LDk3LjI2LS4wMSw2LjU5LTIuNDQsOC04LjExLDQuNzYtMTEuNzEtNi42OS0yMy4zOC0xMy40Ny0zNS4xNi0yMC4wNC0zLjk1LTIuMi01Ljc2LTUuMS01LjcxLTkuNjgsLjE2LTE0LjM5LS4wNC0yOC43OSwuMTEtNDMuMTgsLjA1LTUuMDctMS42Ni04LjY1LTYuMy0xMS4wMy00LjczLTIuNDItOS4yNy01LjIxLTEzLjg2LTcuOS0zLjIxLTEuODktNi4zNC0xLjkyLTkuNTYtLjAzLTQuOTIsMi44OS05Ljg0LDUuNzgtMTQuODUsOC41Mi0zLjg4LDIuMTItNS4zNCw1LjMxLTUuMzIsOS41OSwuMDcsMTQuNTItLjEsMjkuMDUsLjEsNDMuNTcsLjA3LDQuODgtMS43Niw3Ljk2LTYsMTAuMzEtMTEuNjksNi40OC0yMy4yMiwxMy4yMS0zNC44MiwxOS44NC01LjcxLDMuMjYtOC4yMSwxLjg4LTguMjItNC42LS4wMi0xNi4zNCwwLTMyLjY4LDAtNDkuMDJoLS4wOVoiLz48cG9seWdvbiBjbGFzcz0iZCIgcG9pbnRzPSIxNTYuNDggODEuNjIgMTQ4Ljc0IDgxLjYyIDE1My4yOSA4OS41IDE2MS4wMyA4OS41IDE1Ni40OCA4MS42MiAxNTYuNDggODEuNjIiLz48cG9seWdvbiBjbGFzcz0iYiIgcG9pbnRzPSIyMTMuNTcgMTA2LjI0IDIxMS44NiAxMDMuMTMgMjA2LjY4IDk0LjIzIDIwMC45NCA5NC4zIDIwMi41MSA5NyAxODcuOTIgOTcuMDggMTg0LjcxIDkxLjU3IDE3My45NiA5MS42NSAyMzEuOTEgMTgyLjczIDI1My42MyAxNDMuOTIgMjM2LjIgMTEzLjk5IDIzNC40MyAxMTAuOTQgMjMwLjM3IDEwMy45NyAyMzAuMzcgMTAzLjk3IDIxMy41NyAxMDYuMjQiLz48cGF0aCBjbGFzcz0iYyIgZD0iTTI2Ny40Nyw5Ny41M2M0LjU4LTcuODksOS4xNi0xNS43NywxMy42Ni0yMy43LC45OC0xLjcyLDIuMjMtMi40Myw0LjItMi40MiwxMy4zOCwuMDUsMjYuNzYsLjAyLDQwLjE0LC4wMywzLjgxLDAsNC43NSwxLjQ4LDMuMjEsNC45OC00LjE4LDcuMDktOC40NSwxNC4xMy0xMi4yOSwyMS40Mi00LjQ5LDcuNjYtOSwxNS4zLTEzLjQ1LDIyLjk4LTkuOTQsMTcuMTYtMTkuNzUsMzQuNC0yOS44Myw1MS40OC00Ljg1LDguMjItOS42OSwxNi40NS0xNS4yNiwyNC4yMi0xLjIxLDEuNjgtMi40NSwzLjM3LTMuODYsNC44OC0zLjU4LDMuODItNi42MywzLjc3LTEwLjIzLS4wNS0xLjczLTEuODMtNy4xNi05Ljc5LTQuMjYtNS4xMy00LjcyLTcuNC0xMC4zOS0xNS44Mi0xNS4wNy0yMy4yMywxLjUyLTMuNTMsMTcuOTktMzMuMywyMi4zMS00MC43NSwuMzQtLjU4LDE0LjQ0LTIzLjg4LDIwLjcyLTM0LjcxWiIvPjxwb2x5bGluZSBjbGFzcz0iZSIgcG9pbnRzPSIyMjQuNDMgMTcyLjk5IDI0Ny40IDEzMS4xNCAyNDEuMDYgMTIwLjQxIi8+PGc+PHBvbHlnb24gY2xhc3M9ImIiIHBvaW50cz0iMTc5LjQ3IDY4LjI3IDE3My4wNyA2OC40IDE3Ni45NyA3NC44NCAxNzkuMjcgNzQuNzkgMTgyLjkgODAuNzkgMTkzLjM5IDgwLjU3IDE4NyA3MC4wMyAxODAuNjIgNzAuMTYgMTc5LjQ3IDY4LjI3IDE3OS40NyA2OC4yNyIvPjxwb2x5Z29uIGNsYXNzPSJiIiBwb2ludHM9IjE3OC41NiAzNy4zOCAxNzIuMzMgMzcuNTEgMTc2LjEzIDQzLjc4IDE4Mi4zNiA0My42NSAxNzguNTYgMzcuMzggMTc4LjU2IDM3LjM4Ii8+PHBvbHlnb24gY2xhc3M9ImIiIHBvaW50cz0iMTY3LjM3IDQ2LjIzIDE2Mi4xMSA0Ni4zNSAxNjUuMzEgNTEuNjMgMTcwLjU3IDUxLjUyIDE2Ny4zNyA0Ni4yMyAxNjcuMzcgNDYuMjMiLz48cG9seWdvbiBjbGFzcz0iYiIgcG9pbnRzPSIxODkuODIgMjYuNjkgMTg1LjQgMjYuNzggMTg3LjcxIDMwLjU5IDE5Mi4xMyAzMC41IDE4OS44MiAyNi42OSAxODkuODIgMjYuNjkiLz48cG9seWdvbiBjbGFzcz0iYiIgcG9pbnRzPSIxNzkuNTcgNTUuNDMgMTc0LjA0IDU1LjU1IDE3Ni45NCA2MC4zNCAxODIuNDcgNjAuMjIgMTc5LjU3IDU1LjQzIDE3OS41NyA1NS40MyIvPjxwb2x5Z29uIGNsYXNzPSJiIiBwb2ludHM9IjIwNi43NSA1OC40OSAxOTcuNzkgNTguNjggMTk2LjM1IDU2LjMxIDE4OC4yMiA1Ni40OCAxOTIuNDcgNjMuNDkgMTk4LjAyIDYzLjM3IDIwMi4yNCA3MC4zMyAyMTMuNzcgNzAuMDkgMjA2Ljc1IDU4LjQ5IDIwNi43NSA1OC40OSIvPjxwb2x5Z29uIGNsYXNzPSJiIiBwb2ludHM9IjE5Ny4yOSA0Mi45IDE4OS40NSA0My4wNyAxOTMuNTYgNDkuODUgMjAxLjM5IDQ5LjY4IDE5Ny4yOSA0Mi45IDE5Ny4yOSA0Mi45Ii8+PHBvbHlnb24gY2xhc3M9ImIiIHBvaW50cz0iMTYyLjc3IDI4LjU3IDE1OS4xNyAyOC42NSAxNjEuMDYgMzEuNzcgMTY0LjY2IDMxLjY5IDE2Mi43NyAyOC41NyAxNjIuNzcgMjguNTciLz48cG9seWdvbiBjbGFzcz0iYiIgcG9pbnRzPSIyMjIuMjMgODIuNTUgMjA3LjkxIDgyLjg2IDIxMC43NCA4Ny41NCAyMTUuMTMgODcuNDUgMjE3Ljc2IDkxLjc5IDIyNy43IDkxLjU4IDIyMi4yMyA4Mi41NSAyMjIuMjMgODIuNTUiLz48L2c+PHBvbHlnb24gY2xhc3M9ImIiIHBvaW50cz0iMTY2LjExIDU4LjA4IDE2MS43IDU4LjE3IDE2NC4wMSA2MS45OCAxNjguNDIgNjEuODkgMTY2LjExIDU4LjA4IDE2Ni4xMSA1OC4wOCIvPjwvc3ZnPg=="
}

data "coder_parameter" "node_version" {
  name         = "node_version"
  display_name = "Node.js Version"
  description  = "Node.js version to install ('latest', specific version like '18.17.0', or 'none' to disable)"
  type         = "string"
  default      = "latest"
  mutable      = true
  icon         = "/icon/node.svg"
}

data "coder_parameter" "docker_version" {
  name         = "docker_version"
  display_name = "Docker Version"
  description  = "Docker version to install ('latest', specific version like '24.0.0', or 'none' to disable)"
  type         = "string"
  default      = "latest"
  mutable      = true
  icon         = "/icon/docker.svg"
}

data "coder_parameter" "nix_version" {
  name         = "nix_version"
  display_name = "Nix Version"
  description  = "Nix version to install ('latest', specific version like '2.18.0', or 'none' to disable)"
  type         = "string"
  default      = "latest"
  mutable      = true
  icon         = "/icon/nix.svg"
}

data "coder_parameter" "taskfile_version" {
  name         = "taskfile_version"
  display_name = "Taskfile Version"
  description  = "Taskfile version to install ('latest', specific version like '3.31.0', or 'none' to disable)"
  type         = "string"
  default      = "latest"
  mutable      = true
  icon         = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MDAiIGhlaWdodD0iNTAwIiB2aWV3Qm94PSIwIDAgMzc1IDM3NSI+PHBhdGggZmlsbD0iIzI5YmViMCIgZD0iTSAxODcuNTcwMzEyIDE5MC45MzM1OTQgTCAxODcuNTcwMzEyIDM3NSBMIDMwLjA3MDMxMiAyNzkuNTM1MTU2IEwgMzAuMDcwMzEyIDk1LjQ2NDg0NCBaIi8+PHBhdGggZmlsbD0iIzY5ZDJjOCIgZD0iTSAxODcuNTcwMzEyIDE5MC45MzM1OTQgTCAxODcuNTcwMzEyIDM3NSBMIDM0NS4wNzAzMTIgMjc5LjUzNTE1NiBMIDM0NS4wNzAzMTIgOTUuNDY0ODQ0IFoiLz48cGF0aCBmaWxsPSIjOTRkZmQ4IiBkPSJNIDE4Ny41NzAzMTIgMTkwLjkzMzU5NCBMIDMwLjA3MDMxMiA5NS40NjQ4NDQgTCAxODcuNTcwMzEyIDAgTCAzNDUuMDcwMzEyIDk1LjQ2NDg0NCBaIi8+PC9zdmc+"
}


# ---------------------------------------------------------------------------------------------------------------------
# Container Status Data Sources
# ---------------------------------------------------------------------------------------------------------------------
resource "time_sleep" "wait_between_checks" {
  count           = data.coder_workspace.me.transition == "start" ? 1 : 0
  depends_on      = [null_resource.start_container]
  create_duration = "5s"

  triggers = {
    container_id = proxmox_lxc.coder_container[0].id
  }
}

data "http" "container_status" {
  depends_on = [
    proxmox_lxc.coder_container,
    time_sleep.wait_between_checks
  ]

  url = "${var.proxmox_url}/nodes/${local.selected_node}/lxc/${split("/", proxmox_lxc.coder_container[0].id)[2]}/status/current"

  # Skip TLS verification for self-signed certificates
  insecure = var.proxmox_api_insecure == "true"

  request_headers = {
    Authorization = "PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  }

  # Add retry logic
  retry {
    attempts     = 10
    min_delay_ms = 1000
    max_delay_ms = 3000
  }

  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Container status check failed"
    }
  }
}

data "http" "container_ip" {
  count      = data.coder_workspace.me.transition == "start" ? 1 : 0
  depends_on = [data.http.container_status]

  url = "${var.proxmox_url}/nodes/${local.selected_node}/lxc/${split("/", proxmox_lxc.coder_container[0].id)[2]}/interfaces"

  # Skip TLS verification for self-signed certificates
  insecure = var.proxmox_api_insecure == "true"

  request_headers = {
    Authorization = "PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  }

  retry {
    attempts     = 3
    min_delay_ms = 1000
    max_delay_ms = 5000
  }

  lifecycle {
    precondition {
      condition     = contains(["running"], jsondecode(data.http.container_status.response_body).data.status)
      error_message = "Container is not in running state"
    }
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Failed to get container interfaces, status code: ${self.status_code}"
    }
    postcondition {
      condition = anytrue([
        for iface in jsondecode(self.response_body).data :
        iface.name == "eth0" && can(regex("[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}", coalesce(iface.inet, "")))
      ])
      error_message = "No valid IPv4 address found in interfaces: ${jsonencode(jsondecode(self.response_body).data)}"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Local Variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  vm_name       = lower(data.coder_workspace.me.name)
  full_template = "${var.proxmox_template_storage}/${var.proxmox_template_name}"

  # Only try to parse IP if container_ip data source exists
  container_ip = data.coder_workspace.me.transition == "start" ? (
    try(
      [for iface in jsondecode(data.http.container_ip[0].response_body).data :
        iface.inet if iface.name == "eth0" && can(regex("[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}", coalesce(iface.inet, "")))
      ][0],
      "no_ip"
    )
  ) : "no_ip"

  parsed_ip = data.coder_workspace.me.transition == "start" ? (
    regex("^([^/]+)", local.container_ip)[0]
  ) : "no_ip"

  # Tool enablement flags - enabled if version is not "none"
  tool_enabled = {
    golang   = data.coder_parameter.golang_version.value != "none"
    node     = data.coder_parameter.node_version.value != "none"
    docker   = data.coder_parameter.docker_version.value != "none"
    nix      = data.coder_parameter.nix_version.value != "none"
    taskfile = data.coder_parameter.taskfile_version.value != "none"
  }

  # Tool versions (passed directly to scripts for dynamic resolution)
  tool_versions = {
    golang   = data.coder_parameter.golang_version.value
    node     = data.coder_parameter.node_version.value
    docker   = data.coder_parameter.docker_version.value
    nix      = data.coder_parameter.nix_version.value
    taskfile = data.coder_parameter.taskfile_version.value
  }

  # Script configs for all tools (they handle their own conditional logic)
  script_configs = {
    golang = {
      template    = "setup_golang.sh.tftpl"
      output_file = "${path.module}/setup_golang.sh"
      vars = {
        version = local.tool_versions.golang
        enabled = local.tool_enabled.golang
      }
      triggers = {
        version = local.tool_versions.golang
        enabled = local.tool_enabled.golang
      }
    }
    node = {
      template    = "setup_node.sh.tftpl"
      output_file = "${path.module}/setup_node.sh"
      vars = {
        username     = data.coder_workspace_owner.me.name
        node_version = local.tool_versions.node
        enabled      = local.tool_enabled.node
      }
      triggers = {
        node_version = local.tool_versions.node
        enabled      = local.tool_enabled.node
      }
    }
    taskfile = {
      template    = "setup_taskfile.sh.tftpl"
      output_file = "${path.module}/setup_taskfile.sh"
      vars = {
        version = local.tool_versions.taskfile
        enabled = local.tool_enabled.taskfile
      }
      triggers = {
        version = local.tool_versions.taskfile
        enabled = local.tool_enabled.taskfile
      }
    }
    docker = {
      template    = "setup_docker.sh.tftpl"
      output_file = "${path.module}/setup_docker.sh"
      vars = {
        username = data.coder_workspace_owner.me.name
        version  = local.tool_versions.docker
        enabled  = local.tool_enabled.docker
      }
      triggers = {
        version = local.tool_versions.docker
        enabled = local.tool_enabled.docker
      }
    }
    nix = {
      template    = "setup_nix.sh.tftpl"
      output_file = "${path.module}/setup_nix.sh"
      vars = {
        version = local.tool_versions.nix
        enabled = local.tool_enabled.nix
      }
      triggers = {
        version = local.tool_versions.nix
        enabled = local.tool_enabled.nix
      }
    }
  }

  version_hash = sha256(jsonencode({
    versions = local.tool_versions
    enabled  = local.tool_enabled
  }))
}

# ---------------------------------------------------------------------------------------------------------------------
# SSH Key Generation
# ---------------------------------------------------------------------------------------------------------------------
resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

# ---------------------------------------------------------------------------------------------------------------------
# Proxmox Container Configuration
# ---------------------------------------------------------------------------------------------------------------------
resource "proxmox_lxc" "coder_container" {
  count           = var.proxmox_use_lxc ? 1 : 0
  target_node     = local.selected_node
  hostname        = local.vm_name
  ostemplate      = local.full_template
  unprivileged    = true
  start           = true
  onboot          = true
  ssh_public_keys = tls_private_key.ssh_key.public_key_openssh

  features {
    nesting = true
    fuse    = false
    keyctl  = false
    mknod   = false
  }

  rootfs {
    storage = "local"
    size    = "${data.coder_parameter.proxmox_disk_size.value}G"
  }

  cores  = data.coder_parameter.proxmox_cpu_cores.value
  memory = data.coder_parameter.proxmox_memory.value

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Container Management Scripts
# ---------------------------------------------------------------------------------------------------------------------
resource "local_file" "start_container_script" {
  filename = "${path.module}/start_container.sh"
  content = templatefile("scripts/start_container.sh.tftpl", {
    token_id     = var.proxmox_api_token_id
    token_secret = var.proxmox_api_token_secret
    proxmox_url  = var.proxmox_url
    node         = local.selected_node
    container_id = split("/", proxmox_lxc.coder_container[0].id)[2]
  })
}

resource "local_file" "stop_container_script" {
  filename = "${path.module}/stop_container.sh"
  content = templatefile("scripts/stop_container.sh.tftpl", {
    token_id     = var.proxmox_api_token_id
    token_secret = var.proxmox_api_token_secret
    proxmox_url  = var.proxmox_url
    node         = local.selected_node
    container_id = split("/", proxmox_lxc.coder_container[0].id)[2]
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# Container Lifecycle Management
# ---------------------------------------------------------------------------------------------------------------------
resource "null_resource" "validate_auth" {
  count = (var.proxmox_api_auth_method == "token" && (var.proxmox_api_token_id == "" || var.proxmox_api_token_secret == "")) || (var.proxmox_api_auth_method == "username_password" && (var.proxmox_api_username == "" || var.proxmox_api_password == "")) ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'Error: Invalid authentication credentials provided.' && exit 1"
  }
}

resource "null_resource" "start_container" {
  count = data.coder_workspace.me.transition == "start" ? 1 : 0

  depends_on = [
    proxmox_lxc.coder_container,
    local_file.start_container_script
  ]

  triggers = {
    always_run   = timestamp()
    container_id = proxmox_lxc.coder_container[0].id
  }

  provisioner "local-exec" {
    command = <<-EOT
      chmod +x ${local_file.start_container_script.filename}
      ${local_file.start_container_script.filename}
    EOT
  }
}

resource "null_resource" "stop_container" {
  count = data.coder_workspace.me.transition == "stop" ? 1 : 0

  triggers = {
    container_id = proxmox_lxc.coder_container[0].id
  }

  provisioner "local-exec" {
    command = "bash ${local_file.stop_container_script.filename}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Container Setup and User Configuration
# ---------------------------------------------------------------------------------------------------------------------

# Resource to track version changes
resource "null_resource" "version_tracker" {
  triggers = {
    version_hash = local.version_hash
  }
}

# First, create all setup scripts as local files
resource "local_file" "setup_scripts" {
  for_each = local.script_configs

  filename = each.value.output_file
  content  = templatefile("${path.module}/scripts/${each.value.template}", each.value.vars)
}

# Base system setup (apt updates, basic tools)
resource "local_file" "setup_base_script" {
  filename = "${path.module}/setup_base.sh"
  content  = file("${path.module}/scripts/setup_base.sh.tftpl")
}

# User setup
resource "local_file" "setup_users_script" {
  filename = "${path.module}/setup_users.sh"
  content = templatefile("${path.module}/scripts/setup_users.sh.tftpl", {
    username = data.coder_workspace_owner.me.name
  })
}

# Base setup (runs ONLY on first creation)
resource "null_resource" "setup_base_container" {
  # Only run on first workspace creation
  count = (data.coder_workspace.me.start_count == 1) ? 1 : 0

  depends_on = [data.http.container_ip]

  # Prevent any recreation
  lifecycle {
    ignore_changes = all
  }

  provisioner "local-exec" {
    command = "echo 'Running base setup (start_count: ${data.coder_workspace.me.start_count}, transition: ${data.coder_workspace.me.transition})'"
  }

  connection {
    type        = "ssh"
    host        = local.parsed_ip
    user        = "root"
    private_key = tls_private_key.ssh_key.private_key_pem
    timeout     = "5m"
  }

  provisioner "file" {
    source      = local_file.setup_base_script.filename
    destination = "/tmp/setup_base.sh"
  }

  provisioner "file" {
    source      = local_file.setup_users_script.filename
    destination = "/tmp/setup_users.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "bash -x /tmp/setup_base.sh 2>&1 | tee /tmp/setup_base.log",
      "bash -x /tmp/setup_users.sh 2>&1 | tee /tmp/setup_users.log"
    ]
  }
}

# Application setup (runs ONLY on version changes)
resource "null_resource" "setup_applications" {
  # Only run when versions change
  count = (data.coder_workspace.me.transition == "start" &&
  local.version_hash != null) ? 1 : 0

  depends_on = [null_resource.setup_base_container]

  triggers = {
    # Track only version-related changes
    version_hash = local.version_hash
  }

  # Prevent recreation except for version changes
  lifecycle {
    ignore_changes        = all
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command = "echo 'Running application setup (version_hash: ${local.version_hash})'"
  }

  connection {
    type        = "ssh"
    host        = local.parsed_ip
    user        = "root"
    private_key = tls_private_key.ssh_key.private_key_pem
    timeout     = "5m"
  }

  # Copy all setup scripts (they will handle their own conditional logic)
  provisioner "file" {
    source      = local_file.setup_scripts["golang"].filename
    destination = "/tmp/setup_golang.sh"
  }

  provisioner "file" {
    source      = local_file.setup_scripts["taskfile"].filename
    destination = "/tmp/setup_taskfile.sh"
  }

  provisioner "file" {
    source      = local_file.setup_scripts["node"].filename
    destination = "/tmp/setup_node.sh"
  }

  provisioner "file" {
    source      = local_file.setup_scripts["docker"].filename
    destination = "/tmp/setup_docker.sh"
  }

  provisioner "file" {
    source      = local_file.setup_scripts["nix"].filename
    destination = "/tmp/setup_nix.sh"
  }

  provisioner "remote-exec" {
    inline = concat(
      ["chmod +x /tmp/*.sh || true"],
      local.tool_enabled.golang ? ["bash -x /tmp/setup_golang.sh 2>&1 | tee /tmp/setup_golang.log"] : ["echo 'Go disabled, skipping'"],
      local.tool_enabled.taskfile ? ["bash -x /tmp/setup_taskfile.sh 2>&1 | tee /tmp/setup_taskfile.log"] : ["echo 'Taskfile disabled, skipping'"],
      local.tool_enabled.node ? ["bash -x /tmp/setup_node.sh 2>&1 | tee /tmp/setup_node.log"] : ["echo 'Node.js disabled, skipping'"],
      local.tool_enabled.docker ? ["bash -x /tmp/setup_docker.sh 2>&1 | tee /tmp/setup_docker.log"] : ["echo 'Docker disabled, skipping'"],
      local.tool_enabled.nix ? ["bash -x /tmp/setup_nix.sh 2>&1 | tee /tmp/setup_nix.log"] : ["echo 'Nix disabled, skipping'"]
    )
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Coder Agent Configuration
# ---------------------------------------------------------------------------------------------------------------------
resource "coder_agent" "main" {
  depends_on = [null_resource.setup_base_container, null_resource.setup_applications]
  arch       = data.coder_provisioner.me.arch
  os         = data.coder_provisioner.me.os

  # These environment variables allow you to make Git commits right away after creating a
  # workspace. Note that they take precedence over configuration defined in ~/.gitconfig!
  env = {
    GIT_AUTHOR_NAME     = "${data.coder_workspace_owner.me.name}"
    GIT_COMMITTER_NAME  = "${data.coder_workspace_owner.me.name}"
    GIT_AUTHOR_EMAIL    = var.git_committer_email
    GIT_COMMITTER_EMAIL = var.git_committer_email
  }

  # The following metadata blocks are optional. They are used to display
  # information about your workspace in the dashboard. You can remove them
  # if you don't want to display any information.
  # For basic resources, you can use the `coder stat` command.
  # If you need more control, you can write your own script.
  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Disk Usage"
    key          = "2_disk_usage"
    script       = "coder stat disk --path /home/${data.coder_workspace_owner.me.name}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "Load Average"
    key          = "3_load_average"
    script       = <<EOT
        awk '{print $1,$2,$3}' /proc/loadavg
    EOT
    interval     = 1
    timeout      = 1
  }
}

locals {
  coder_env_vars = {
    CODER_AGENT_TOKEN = coder_agent.main.token
    CODER_AGENT_URL   = data.coder_workspace.me.access_url

    CODER_WORKSPACE_ID   = data.coder_workspace.me.id
    CODER_WORKSPACE_NAME = data.coder_workspace.me.name
    CODER_USERNAME       = data.coder_workspace_owner.me.name
    CODER_USER_EMAIL     = data.coder_workspace_owner.me.email
  }
}

resource "local_file" "setup_coder_agent_script" {
  count    = data.coder_workspace.me.transition == "start" ? 1 : 0
  filename = "${path.module}/setup_coder_agent.sh"
  content = templatefile("${path.module}/scripts/setup_coder_agent.sh.tftpl", {
    coder_agent_url = local.coder_env_vars.CODER_AGENT_URL
  })
}

resource "local_file" "coder_agent_service" {
  count    = data.coder_workspace.me.transition == "start" ? 1 : 0
  filename = "${path.module}/coder-agent.service"
  content = templatefile("${path.module}/configs/coder-agent.service.tftpl", {
    username          = data.coder_workspace_owner.me.name
    coder_agent_token = local.coder_env_vars.CODER_AGENT_TOKEN
    coder_agent_url   = local.coder_env_vars.CODER_AGENT_URL
  })
}

resource "null_resource" "setup_coder_agent" {
  depends_on = [
    coder_agent.main,
    local_file.setup_coder_agent_script,
    local_file.coder_agent_service
  ]
  count = data.coder_workspace.me.transition == "start" ? 1 : 0

  triggers = {
    agent_token     = coder_agent.main.token
    service_content = local_file.coder_agent_service[count.index].content
    setup_script    = local_file.setup_coder_agent_script[count.index].content
    agent_url       = data.coder_workspace.me.access_url
    workspace_owner = data.coder_workspace_owner.me.name
    workspace_name  = data.coder_workspace.me.name
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = local.parsed_ip
    port        = 22
    timeout     = "2m"
    agent       = false
  }

  provisioner "file" {
    source      = local_file.setup_coder_agent_script[count.index].filename
    destination = "/tmp/setup_coder_agent.sh"
  }

  provisioner "file" {
    source      = local_file.coder_agent_service[count.index].filename
    destination = "/etc/systemd/system/coder-agent.service"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 644 /etc/systemd/system/coder-agent.service",
      "chmod +x /tmp/setup_coder_agent.sh",
      "bash -x /tmp/setup_coder_agent.sh 2>&1 | tee /tmp/setup_coder_agent.log",
      "systemctl daemon-reload",
      "systemctl enable coder-agent",
      "systemctl restart coder-agent"
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Code-Server Configuration
# ---------------------------------------------------------------------------------------------------------------------
module "code-server" {
  count = data.coder_workspace.me.transition == "start" ? 1 : 0

  agent_id     = coder_agent.main.id
  source       = "registry.coder.com/modules/code-server/coder"
  display_name = "VS Code Server"
  share        = "owner"
  extensions = ["dracula-theme.theme-dracula", "PKief.material-icon-theme",
  "golang.Go", "esbenp.prettier-vscode"]
  settings = {
    "workbench.colorTheme" = "Dracula Theme",
    "workbench.iconTheme"  = "material-icon-theme",
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Desktop launchers
# ---------------------------------------------------------------------------------------------------------------------
module "cursor" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/modules/cursor/coder"
  version  = "1.0.19"
  agent_id = coder_agent.main.id
  folder   = "/home/${data.coder_workspace_owner.me.name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Debug Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "tool_configuration" {
  value = {
    enabled_tools = local.tool_enabled
    tool_versions = local.tool_versions
  }
  description = "Tool enablement status and versions"
}
