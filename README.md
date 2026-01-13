# Ubuntu Post-Installation Setup Script

A comprehensive bash script for setting up Ubuntu after a fresh installation. Features a user-friendly menu interface for installing essential packages and Docker.

## Features

- **Menu-driven interface** - Easy to navigate options
- **Headless installation mode** - Quick setup for servers
- **GUI installation mode** - Desktop setup with essential packages + Chrome
- **System updates** - apt update and upgrade
- **Essential packages** - Installs curl, git, htop, and wget
- **Docker installation** - Official Docker Engine + Docker Compose using the apt repository method
- **Node.js installation** - LTS version from NodeSource repository
- **VS Code installation** - Official Visual Studio Code from Microsoft repository
- **Chrome installation** - Google Chrome stable version
- **Color-coded output** - Clear visual feedback
- **Error handling** - Robust error checking and user feedback

## Requirements

- Ubuntu (tested on 20.04, 22.04, and 24.04)
- sudo privileges
- Internet connection

## Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/BogieDaKat/ubuntuscript/main/ubuntu-setup.sh
```

Or clone the repository:
```bash
git clone https://github.com/BogieDaKat/ubuntuscript.git
cd ubuntuscript
```

2. Make the script executable:
```bash
chmod +x ubuntu-setup.sh
```

3. Run the script with sudo:
```bash
sudo bash ubuntu-setup.sh
```

## Usage

### Main Menu Options

1. **Headless Installation Setup** - Runs apt update, apt upgrade, and installs essential packages (ideal for servers)
2. **GUI Installation Setup** - Runs apt update, apt upgrade, installs essential packages + Google Chrome (ideal for desktop)
3. **Software Installation Menu** - Access the software installation submenu
4. **Update System Only** - Only runs apt update and apt upgrade
5. **Install Essential Packages Only** - Only installs curl, git, htop, and wget
6. **Exit** - Exit the script

### Software Installation Menu

1. **Install Docker & Docker Compose** - Installs Docker Engine using the official Docker apt repository
2. **Install Node.js (LTS)** - Installs Node.js LTS version from NodeSource repository
3. **Install Visual Studio Code** - Installs VS Code from Microsoft's official repository
4. **Install Google Chrome** - Downloads and installs Google Chrome stable version
5. **Update System** - Runs system updates
6. **Install Essential Packages** - Installs essential tools
7. **Back to Main Menu** - Return to main menu

## Software Installation Details

### Docker
The script installs Docker using the [official Docker documentation](https://docs.docker.com/engine/install/ubuntu/) method:
- Adds Docker's official GPG key
- Sets up the Docker apt repository
- Installs docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, and docker-compose-plugin
- Verifies installation with hello-world test
- Optionally adds a user to the docker group for non-sudo Docker usage

### Node.js
Installs Node.js LTS version from the NodeSource repository:
- Adds NodeSource repository for the latest LTS version
- Installs Node.js and npm
- Verifies installation by displaying versions

### Visual Studio Code
Installs VS Code using the [official Microsoft repository](https://code.visualstudio.com/docs/setup/linux):
- Adds Microsoft's GPG key
- Sets up the VS Code apt repository
- Installs the latest stable version of VS Code
- Verifies installation

### Google Chrome
Downloads and installs Google Chrome stable version:
- Downloads the latest stable .deb package directly from Google
- Installs using apt
- Cleans up installation file automatically

## Post-Installation

After installation, you may need to:

1. **Docker**: Log out and log back in for docker group permissions to take effect (if you added a user to the docker group)
2. **Docker**: Verify Docker is running: `sudo systemctl status docker`
3. **Node.js**: Verify installation: `node --version && npm --version`
4. **VS Code**: Launch from terminal with `code` or from application menu
5. **Chrome**: Launch from application menu or terminal with `google-chrome`

## License

MIT License

## Contributing

Feel free to submit issues and pull requests!
post install script for ubuntu, for both GUI and headless installs
