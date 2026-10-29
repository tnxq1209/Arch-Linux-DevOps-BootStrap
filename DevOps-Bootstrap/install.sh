#!/bin/bash

set -eou pipefail

log() {
    echo "LOG: Installing $@..."
}

error() {
    echo "ERROR: $@ Installation failed."
    exit 1
}

#Variables
architecture=$(uname -m)
kernel=$(uname -r)

source /etc/os-release
echo "--------------------------------"
echo "OS:           $NAME"
echo "OS_FAMILY:    $ID_LIKE"
echo "Architecture: $architecture"
echo "Kernel:       $kernel"
echo "--------------------------------"

validate_os() {
    if [[ "$ID_LIKE" = *arch* ]]; then
        echo "Detected Arch Linux or derivative."
    else 
        error "Unsupported OS: $NAME."
    fi   
}

validate_user() {
    echo "Validating user permissions..."
    if [[ $UID -eq 0 ]]; then
        echo "Root user detected."
        error "This script should not be run as root."
    else
        echo "User validation passed."
    fi
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        error "Required dependencies $1 are not installed."
    else
        echo "Dependency check passed: $1 is installed."
    fi
}
validate_user
validate_os
dependencies=(
    sudo
    pacman
)

for dep in "${dependencies[@]}"; do
    check_command "$dep"
done

install_packages() {
    if pacman -Q "$1" &> /dev/null; then
        echo "$1 is already installed."
    else
        log "$1"
        yes | sudo pacman -S --needed "$1" 
    fi
}
packages=(
    kubectl
    terraform
    ansible
)
for pkg in "${packages[@]}"; do
    install_packages "$pkg"
done
