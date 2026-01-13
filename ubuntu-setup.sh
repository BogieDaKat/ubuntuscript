#!/bin/bash

# Ubuntu Post-Installation Setup Script
# Must be run with sudo

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run with sudo${NC}"
    echo "Usage: sudo bash $0"
    exit 1
fi

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to pause and wait for user
pause() {
    echo ""
    read -p "Press [Enter] to continue..."
}

# Function to update and upgrade system
update_system() {
    print_info "Updating package lists..."
    apt update
    if [ $? -eq 0 ]; then
        print_success "Package lists updated successfully"
    else
        print_error "Failed to update package lists"
        return 1
    fi
    
    print_info "Upgrading installed packages..."
    apt upgrade -y
    if [ $? -eq 0 ]; then
        print_success "System upgraded successfully"
    else
        print_error "Failed to upgrade system"
        return 1
    fi
}

# Function to install essential packages
install_essentials() {
    print_info "Checking and installing essential packages..."
    
    local packages=("curl" "git" "htop" "wget")
    local to_install=()
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            print_info "$package is not installed. Will install."
            to_install+=("$package")
        else
            print_success "$package is already installed"
        fi
    done
    
    if [ ${#to_install[@]} -gt 0 ]; then
        print_info "Installing: ${to_install[*]}"
        apt install -y "${to_install[@]}"
        if [ $? -eq 0 ]; then
            print_success "Essential packages installed successfully"
        else
            print_error "Failed to install some packages"
            return 1
        fi
    else
        print_success "All essential packages are already installed"
    fi
}

# Function to install Google Chrome
install_chrome() {
    print_info "Starting Google Chrome installation..."
    
    # Check if Chrome is already installed
    if command -v google-chrome &> /dev/null; then
        print_warning "Google Chrome is already installed"
        google-chrome --version
        read -p "Do you want to reinstall Chrome? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    # Download Chrome .deb package
    print_info "Downloading Google Chrome..."
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    
    if [ $? -eq 0 ]; then
        print_success "Download complete"
        
        # Install Chrome
        print_info "Installing Google Chrome..."
        apt install -y ./google-chrome-stable_current_amd64.deb
        
        if [ $? -eq 0 ]; then
            print_success "Google Chrome installed successfully"
            google-chrome --version
            
            # Clean up the .deb file
            print_info "Cleaning up installation file..."
            rm -f google-chrome-stable_current_amd64.deb
        else
            print_error "Failed to install Google Chrome"
            rm -f google-chrome-stable_current_amd64.deb
            return 1
        fi
    else
        print_error "Failed to download Google Chrome"
        return 1
    fi
}

# Function to install Node.js
install_nodejs() {
    print_info "Starting Node.js installation..."
    
    # Check if Node.js is already installed
    if command -v node &> /dev/null; then
        print_warning "Node.js is already installed"
        node --version
        npm --version
        read -p "Do you want to reinstall Node.js? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    # Install Node.js from NodeSource repository (LTS version)
    print_info "Adding NodeSource repository..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    
    if [ $? -eq 0 ]; then
        print_info "Installing Node.js..."
        apt install -y nodejs
        
        if [ $? -eq 0 ]; then
            print_success "Node.js installed successfully"
            node --version
            npm --version
        else
            print_error "Failed to install Node.js"
            return 1
        fi
    else
        print_error "Failed to add NodeSource repository"
        return 1
    fi
}

# Function to install VS Code
install_vscode() {
    print_info "Starting VS Code installation..."
    
    # Check if VS Code is already installed
    if command -v code &> /dev/null; then
        print_warning "VS Code is already installed"
        code --version
        read -p "Do you want to reinstall VS Code? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    # Install prerequisites
    print_info "Installing VS Code prerequisites..."
    apt install -y wget gpg
    
    # Add Microsoft's GPG key
    print_info "Adding Microsoft's GPG key..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    rm -f packages.microsoft.gpg
    
    # Add VS Code repository
    print_info "Adding VS Code repository..."
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
        tee /etc/apt/sources.list.d/vscode.list > /dev/null
    
    # Update package index
    print_info "Updating package index..."
    apt update
    
    # Install VS Code
    print_info "Installing Visual Studio Code..."
    apt install -y code
    
    if [ $? -eq 0 ]; then
        print_success "VS Code installed successfully"
        code --version
    else
        print_error "Failed to install VS Code"
        return 1
    fi
}

# Function to install Docker
install_docker() {
    print_info "Starting Docker installation..."
    
    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        print_warning "Docker is already installed"
        docker --version
        read -p "Do you want to reinstall Docker? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    # Uninstall old versions
    print_info "Removing old Docker versions if any..."
    apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null
    
    # Install prerequisites
    print_info "Installing Docker prerequisites..."
    apt install -y ca-certificates curl
    
    # Add Docker's official GPG key
    print_info "Adding Docker's official GPG key..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add the Docker repository to Apt sources
    print_info "Adding Docker repository..."
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF


    # Update package index
    print_info "Updating package index..."
    apt update
    
    # Install Docker Engine, CLI, containerd, and plugins
    print_info "Installing Docker Engine and components..."
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    if [ $? -eq 0 ]; then
        print_success "Docker installed successfully"
        
        # Verify installation
        print_info "Verifying Docker installation..."
        systemctl start docker
        systemctl enable docker
        
        docker --version
        docker compose version
        
        # Test Docker
        print_info "Running Docker hello-world test..."
        docker run hello-world
        
        if [ $? -eq 0 ]; then
            print_success "Docker is working correctly!"
            
            # Offer to add user to docker group
            echo ""
            print_info "To run Docker without sudo, you need to add your user to the docker group"
            read -p "Enter username to add to docker group (or press Enter to skip): " username
            if [ ! -z "$username" ]; then
                usermod -aG docker "$username"
                print_success "User $username added to docker group"
                print_warning "You need to log out and back in for this to take effect"
            fi
        else
            print_error "Docker test failed"
        fi
    else
        print_error "Failed to install Docker"
        return 1
    fi
}

# Function to display headless setup menu
headless_setup() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Headless Installation Setup         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    update_system
    echo ""
    install_essentials
    
    pause
}

# Function to display GUI setup menu
gui_setup() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   GUI Installation Setup              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    update_system
    echo ""
    install_essentials
    echo ""
    install_chrome
    
    pause
}

# Function to display installation menu
installation_menu() {
    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   Software Installation Menu          ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo "  1) Install Docker & Docker Compose"
        echo "  2) Install Node.js (LTS)"
        echo "  3) Install Visual Studio Code"
        echo "  4) Install Google Chrome"
        echo "  5) Update System"
        echo "  6) Install Essential Packages"
        echo "  7) Back to Main Menu"
        echo ""
        read -p "Select an option [1-7]: " install_choice
        
        case $install_choice in
            1)
                echo ""
                install_docker
                pause
                ;;
            2)
                echo ""
                install_nodejs
                pause
                ;;
            3)
                echo ""
                install_vscode
                pause
                ;;
            4)
                echo ""
                install_chrome
                pause
                ;;
            5)
                echo ""
                update_system
                pause
                ;;
            6)
                echo ""
                install_essentials
                pause
                ;;
            7)
                break
                ;;
            *)
                print_error "Invalid option. Please select 1-7"
                sleep 2
                ;;
        esac
    done
}

# Main menu function
main_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║   Ubuntu Post-Installation Setup      ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo "  1) Headless Installation Setup"
        echo "  2) GUI Installation Setup"
        echo "  3) Software Installation Menu"
        echo "  4) Update System Only"
        echo "  5) Install Essential Packages Only"
        echo "  6) Exit"
        echo ""
        read -p "Select an option [1-6]: " choice
        
        case $choice in
            1)
                headless_setup
                ;;
            2)
                gui_setup
                ;;
            3)
                installation_menu
                ;;
            4)
                echo ""
                update_system
                pause
                ;;
            5)
                echo ""
                install_essentials
                pause
                ;;
            6)
                echo ""
                print_success "Setup complete. Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-6"
                sleep 2
                ;;
        esac
    done
}

# Script entry point
clear
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}   Ubuntu Post-Installation Setup        ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
print_info "Starting setup script..."
sleep 1

# Start main menu
main_menu
