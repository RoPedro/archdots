#!/bin/bash

LOG_FILE="main.log"

source ./applications/headless/packages.sh
source ./applications/desktop/packages.sh
source ./utils.sh

main() {
    check_configure_git

    if ! command -v yay &>/dev/null; then
        echo "Yay is not installed. Installing yay..."
        install_yay
    else
        echo "Yay is already installed."
    fi

    install_packages
    install_tpm

    sudo chsh -s $(which zsh) $USER

    copy_dotfiles
    copy_wallpapers

    DOTFILES_DIR=$HOME/.dotfiles
    (
        cd $DOTFILES_DIR

        if [ -d keyd ]; then
            sudo stow -t / keyd # keyd needs stow since it's /etc
        fi

        stow *
    )

    echo "Configuration complete, logout recommended."
}

main 2>&1 | tee "$LOG_FILE"
