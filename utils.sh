install_yay() {
    sudo pacman -S --needed git base-devel --noconfirm

    tmp_dir=$(mktemp -d)

    git clone https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin"
    makepkg -si --noconfirm --cwd "$tmp_dir/yay-bin"

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

btop_configure() {
    cp $HOME/linuxtools-term/dotfiles/btop.conf $HOME/.config/btop/
}

asdf_configure() {
    if ! command -v asdf &>/dev/null; then
        echo "Installing asdf..."

        git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.10.1
        echo ". $HOME/.asdf/asdf.sh" >>$HOME/.zshrc

        . "$HOME/.asdf/asdf.sh"
    else
        echo "asdf already installed, skipping..."
    fi
}

# Clones repositories
clone_repositories() {
    # Clones powerlevel10k
    if [ -d "$HOME/powerlevel10k" ]; then
        echo "Powerlevel10k directory already exists. Skipping git clone."
    else
        git clone --depth=2 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k" || {
            echo "Failed to clone Powerlevel10k repository"
            return 1
        }
    fi

    echo "Installing lazyvim"
    rm -rf "$HOME/.config/nvim" # Remove existing nvim directory before cloning
    git clone https://github.com/LazyVim/starter $HOME/.config/nvim || {
        echo "Failed to clone LazyVim repository"
        return 1
    }
    rm -rf $HOME/.config/nvim/.git

    echo "Repositories cloned."
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
zsh_configurations() {
    echo "Configuring Zsh..."

    # Adding path
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>$HOME/.zshrc

    cp -afv $HOME/linuxtools-term/dotfiles/shell $HOME/.zsh

    echo "Adding themes and aliases..."
    # Powerlevel10k and Zsh-autosuggestions
    echo 'source $HOME/powerlevel10k/powerlevel10k.zsh-theme' >>$HOME/.zshrc
    echo 'source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh' >>$HOME/.zshrc
    echo 'source $HOME/.zsh/shell/rc' >>$HOME/.zshrc
    echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>$HOME/.zshrc

    # ------ TERMINAL KEYBINDINGS ------ #
    # Creates zsh config directory
    if [[ ! -d /usr/share/zsh ]]; then
        sudo mkdir /usr/share/zsh
    fi

    # Moves the keybindings dotfile
    if [[ -f $HOME/linuxtools-term/dotfiles/zsh-keybindings ]]; then
        sudo cp $HOME/linuxtools-term/dotfiles/zsh-keybindings /usr/share/zsh/
    else
        echo "Source file not found."
    fi

    # Sourcing keybindings
    cat <<'EOF' >>$HOME/.zshrc
if [[ -e /usr/share/zsh/zsh-keybindings ]]; then
    source /usr/share/zsh/zsh-keybindings
fi
EOF

    echo "Zsh configurations complete."
}

# Configures Tmux
tmux_configurations() {
    echo "Configuring Tmux..."

    # Installing theme
    mkdir -p $HOME/.config/tmux/plugins/catppuccin
    git clone -b v2.1.2 https://github.com/catppuccin/tmux.git $HOME/.config/tmux/plugins/catppuccin/tmux

    if [ -f $HOME/.tmux.conf ]; then
        echo "tmux.conf already exists. copying files"
        cat $HOME/linuxtools-term/dotfiles/.tmux.conf >>$HOME/.tmux.conf
    else
        echo "Creating .tmux.conf"
        cp $HOME/linuxtools-term/dotfiles/.tmux.conf ~
    fi
}

nvim_config() {
    THEME_DIR=$HOME/.config/nvim/lua/plugins/
    SELF_PATH=$HOME/linuxtools-term

    cp -v $SELF_PATH/dotfiles/nvim/catppuccin.lua $HOME/.config/nvim/lua/plugins/

    if [ ! -f $THEME_DIR/catppuccin.lua ]; then
        echo "Neovim theme was not installed."
    else
        echo "Neovim theme installed successfully."
    fi
}

p10k_configuration() {
    echo "Configuring p10k..."
    if [ -f $HOME/.p10k.zsh ]; then
        echo "p10.zsh already exists. copying files"
        cat $HOME/linuxtools-term/dotfiles/.p10k.zsh >>$HOME/.p10k.zsh
    else
        echo "Creating .p10k.zsh"
        cp $HOME/linuxtools-term/dotfiles/.p10k.zsh ~
    fi

    # Sources p10k.zsh
    echo -e "\n[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh " >>$HOME/.zshrc
}
