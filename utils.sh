install_yay() {
    sudo pacman -S --needed git base-devel --noconfirm

    tmp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin"

    (
        cd "$tmp_dir/yay-bin" || exit 1
        makepkg -si --noconfirm
    )

    rm -rf "$tmp_dir"
}

install_packages() {
    # Install packages with error handling
    echo "Installing terminal apt pkgs..."
    for package in "${packages[@]}"; do
        yay -S --noconfirm $package || {
            echo "Failed to install $package, skipping..."
        }
    done

    echo "Installed pkgs: ${packages[*]}"

    echo "Finished installing terminal packages."
}

# tmux plugin manager can't be on dotfiles
# because it's going to be treatedas a submodule
install_tpm() {
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

check_configure_git() {
    # Check if Git is installed
    if ! command -v git &>/dev/null; then
        echo "Git is not installed. Please install Git to continue."
        return 1
    fi

    # Check if git config user.name is set
    if [ -z "$(git config --get user.name)" ]; then
        read -p "Git username not configured. Please enter your Git username: " username
        git config --global user.name "$username"
    fi

    # Check if git config user.email is set
    if [ -z "$(git config --get user.email)" ]; then
        read -p "Git email not configured. Please enter your Git email: " email
        git config --global user.email "$email"
    fi

    echo "Git configuration completed."
}

# Configures main shell and main theme
copy_dotfiles() {
    git clone https://github.com/RoPedro/dotfiles.git $HOME/.dotfiles

    echo "dotfiles cloned."
}
