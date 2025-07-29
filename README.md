# Coder Templates

A collection of production-ready [Coder](https://coder.com) workspace templates for various infrastructure providers and development environments.

## Overview

This repository contains Terraform-based templates that provision development workspaces using Coder. Each template is designed to be flexible, secure, and easy to deploy in production environments.

## Available Templates

### 🖥️ Proxmox Template

**Location**: [`proxmox/`](./proxmox/)

A comprehensive template for provisioning Coder workspaces as Proxmox LXC containers or QEMU VMs.

**Key Features:**

- **Dual provisioning modes**: LXC containers or QEMU VMs
- **Development tools**: Optional Docker, Go, Node.js/NVM, Nix, and Taskfile
- **Smart node selection**: Flexible cluster node targeting
- **VS Code Server**: Automatic setup and integration
- **Cloud-init support**: For QEMU VM initialization
- **Security**: API token authentication and TLS options

**Perfect for:**

- Self-hosted development environments
- Teams using Proxmox infrastructure
- Organizations requiring full control over their development stack

[📖 View Proxmox Template Documentation](./proxmox/README.md)

## Quick Start

1. **Choose a template** from the available options above
2. **Navigate to the template directory** (e.g., `cd proxmox/`)
3. **Follow the template-specific README** for detailed setup instructions
4. **Configure your variables** using the provided `variables.yaml.example` files
5. **Deploy with Coder** using `coder templates push --variables-file variables.yaml`

## Template Structure

Each template follows a consistent structure:

```
template-name/
├── README.md              # Template-specific documentation
├── main.tf               # Main Terraform configuration
├── variables.tf          # Input variables
├── variables.yaml        # Example configuration for Coder CLI
├── scripts/              # Setup and configuration scripts
├── configs/              # Configuration files
└── icons/                # Template icons
```

## Development Philosophy

Our templates are built with these principles:

- **🔒 Security First**: Secure defaults, proper authentication, and minimal attack surface
- **🚀 Production Ready**: Tested configurations suitable for enterprise use
- **🎛️ Configurable**: Flexible options without overwhelming complexity
- **📚 Well Documented**: Clear documentation and examples
- **🔄 Maintainable**: Clean code structure and consistent patterns

## Contributing

We welcome contributions! Please:

1. Follow the existing template structure and patterns
2. Include comprehensive documentation
3. Test your templates thoroughly
4. Update this main README when adding new templates
5. Use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages

## Requirements

- [Coder](https://coder.com) v2.0+
- [Terraform](https://terraform.io) v1.0+
- Infrastructure provider access (Proxmox, AWS, etc.)

## Support

- 📖 **Documentation**: Check the template-specific README files
- 🐛 **Issues**: Report bugs via GitHub Issues
- 💬 **Discussions**: Use GitHub Discussions for questions

## License

This project is licensed under the [MIT License](LICENSE). See the LICENSE file for details.
