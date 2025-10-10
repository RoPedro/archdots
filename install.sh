#!/bin/bash

LOG_FILE="main.log"

source ./applications/headless/packages.sh
source ./utils.sh

main() {
    check_configure_git
    install_yay
    install_packages

    sudo chsh -s $(which zsh) $USER

    copy_dotfiles

    echo "Configuration complete. Run "source ~/.zshrc" and "source ~/.tmux.conf" to apply changes."
}

main 2>&1 | tee "$LOG_FILE"
