---
display_name: Proxmox Development Environment
description: A template to provision coder workspaces as proxmox lxc containers or qemu VMs
icon: icons/proxmox.png
maintainer_github: https://github.com/fkmeland/coder-templates
verified: true
tags:
  - proxmox
  - lxc
  - qemu
  - container
  - workspace
  - coder
---

# A template to provision coder workspaces as proxmox lxc containers or qemu VMs

This template allows you to create workspaces as proxmox lxc containers or qemu VMs.

## Features

1. **Flexible Provisioning**: Create workspaces as either Proxmox LXC containers or QEMU VMs.
2. **Dynamic Node Selection**: Automatically discover and select from available Proxmox cluster nodes (requires API token authentication).
3. **VS Code Server Integration**: Automatic setup and access to VS Code Server.
4. **Customizable Resources**: Specify disk size, CPU cores, memory, and CPU sockets.
5. **Cloud-Init Integration**: Use cloud-init for initial VM configuration.
6. **Proxmox API Authentication**: Support for both username/password and API token methods.
7. **Insecure TLS Option**: Option to disable TLS verification if needed.
8. **Automatic Coder Agent Setup**: Coder agent configured to run on startup.
9. **Network Configuration**: DHCP networking for both LXC containers and QEMU VMs.
10. **Template Cloning**: Specify a template to clone for QEMU VMs.
11. **Workspace Naming**: Automatic generation based on Coder workspace information.
12. **User Creation**: Creates user account matching the Coder workspace owner.
13. **Sudo Access**: Grants sudo access to the created user account.
14. **VM Lifecycle Management**: Stops the VM when the Coder workspace is stopped.
15. **LXC-specific Features**: Unprivileged containers, nesting support, random password generation.
16. **QEMU-specific Features**: KVM virtualization, SCSI disk configuration, cloud-init integration.
17. **Logging and Debugging**: Detailed logging for the Proxmox provider.
18. **Development Tools**: Optional installation of Go, Node.js/NVM, Docker, Nix, and Taskfile with configurable versions.

These features provide a flexible and powerful setup for creating Coder workspaces on Proxmox, catering to different use cases and preferences.

## Development Tools

This template includes configurable development tools with a clean, simplified interface:

- **Docker** - Container runtime
- **Go** - Programming language
- **Node.js** - JavaScript runtime with NVM
- **Nix** - Package manager for reproducible environments
- **Taskfile** - Modern task runner and build tool

### Simple Configuration

Each tool uses a **single version field** with three options:

- **`latest`** - Install the latest version (default)
- **`1.21.0`** - Install a specific version (example)
- **`none`** - Skip installation (disabled)

No separate enable/disable toggles needed - just set the version!

## Template Requirements

This Coder template works with standard Ubuntu LXC templates available in Proxmox. The default configuration uses:

- **Template Name**: `coder-workspace_24.04.tar.gz` (Ubuntu 24.04 LTS)
- **Template Type**: Standard Ubuntu LXC container template
- **Storage Location**: `local:vztmpl` (default Proxmox template storage)

### Using Different Ubuntu Versions

You can use any Ubuntu LXC template by updating the `proxmox_template_name` variable:

```yaml
# For Ubuntu 22.04
proxmox_template_name: "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"

# For Ubuntu 24.04 (default)
proxmox_template_name: "coder-workspace_24.04.tar.gz"
```

### Template Download

Ubuntu LXC templates can be downloaded directly in Proxmox:

1. Go to your Proxmox node → Storage → Templates
2. Download the desired Ubuntu version
3. Update the `proxmox_template_name` variable to match

**Note**: The template name `coder-workspace_24.04.tar.gz` is just a renamed standard Ubuntu 24.04 LTS template - no special modifications are required.

## Configuration

1. **Copy the example configuration**:

   ```bash
   cp variables.yaml.example variables.yaml
   ```

2. **Edit your configuration** with your Proxmox details:

   ```bash
   nano variables.yaml
   ```

3. **Deploy the template**:
   ```bash
   coder templates push --variables-file variables.yaml
   ```

## Cluster Node Selection

This template provides simple and flexible cluster node selection through a single text input field. This approach:

- **Clean interface** - Single text input instead of cluttered radio buttons
- **Maximum flexibility** - Enter any node name directly
- **Smart defaults** - Pre-filled with your most common node
- **No API dependencies** - Works reliably every time
- **Universal compatibility** - Works with any authentication method

### How It Works

Users see a single **"Proxmox Target Node"** text input field with:

- **Smart default**: Pre-filled with the value from `proxmox_default_vm_target_node` (defaults to `pve01`)
- **Clear guidance**: Description shows common examples (pve01, pve02, pve03)
- **Full flexibility**: Can enter any node name in your cluster

### Configuration Options

#### Use Default Behavior (Recommended)

The template defaults to `pve01` which works for most Proxmox installations.

#### Customize Default Node

Set the `proxmox_default_vm_target_node` variable to specify your preferred default:

```hcl
proxmox_default_vm_target_node = "your-preferred-node"
```

### Why This Approach?

**Coder Limitation**: Currently, Coder only supports radio buttons for parameter options, not dropdowns ([GitHub Issue #10264](https://github.com/coder/coder/issues/10264)). Radio buttons become cluttered with multiple options.

**Our Solution**: A single text input provides:

- ✅ **Clean UI** - No radio button clutter
- ✅ **Maximum flexibility** - Support for any node name
- ✅ **Better UX** - Users can type faster than clicking radio buttons
- ✅ **Future-proof** - Works regardless of cluster size

### Benefits

- **Clean interface**: Single text field instead of multiple radio buttons
- **No API dependency**: Works regardless of API connectivity during template push
- **Maximum flexibility**: Support for any node name in your cluster
- **Universal compatibility**: Works with any authentication method
- **Beautiful UI**: Proper Proxmox icon and professional appearance
