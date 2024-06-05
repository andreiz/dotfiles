#!/usr/bin/env bash

main() {
    ask_for_sudo
    install_xcode_command_line_tools
    clone_dotfiles_repo
    install_homebrew
    install_packages_with_brewfile
    install_pip_packages
    setup_symlinks
    configure_macos_defaults
    update_login_items
}

DOTFILES_REPO=~/projects/dotfiles
export PATH=/usr/local/bin:$PATH

function ask_for_sudo() {
    info "Prompting for sudo password"
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; \
            sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
        success "Sudo password updated"
    else
        error "Sudo password update failed"
        exit 1
    fi
}

function install_xcode_command_line_tools() {
    info "Installing Xcode command line tools"

    if xcode-select --print-path &>/dev/null; then
        success "Xcode command line tools already exists"
    else
        xcode-select --install
        while true; do
            if xcode-select --print-path 2>/dev/null; then
                success "Xcode command line tools installation succeeded"
                break
            else
                substep "Xcode command line tools still installing..."
                sleep 20
            fi
        done
    fi
}

function clone_dotfiles_repo() {
    info "Cloning dotfiles repository into ${DOTFILES_REPO}"
    if test -e $DOTFILES_REPO; then
        substep "${DOTFILES_REPO} already exists"
        pull_latest $DOTFILES_REPO
        success "Pull successful in ${DOTFILES_REPO} repository"
    else
        url=https://github.com/andreiz/dotfiles.git
        if git clone "$url" $DOTFILES_REPO && \
           git -C $DOTFILES_REPO remote set-url origin git@github.com:andreiz/dotfiles.git; then
            success "Dotfiles repository cloned into ${DOTFILES_REPO}"
        else
            error "Dotfiles repository cloning failed"
            exit 1
        fi
    fi
}

function install_homebrew() {
    info "Installing Homebrew"
    if hash brew 2>/dev/null; then
        success "Homebrew already exists"
    else
        url=https://raw.githubusercontent.com/Homebrew/install/master/install.sh
        if yes | /bin/bash -c "$(curl -fsSL ${url})"; then
            success "Homebrew installation succeeded"
        else
            error "Homebrew installation failed"
            exit 1
        fi
    fi
}


function install_packages_with_brewfile() {
    info "Installing Brewfile packages"

    BREWFILE=${DOTFILES_REPO}/brew/Brewfile

    if brew bundle check --file="$BREWFILE" &> /dev/null; then
        success "Brewfile packages are already installed"
    else
        export HOMEBREW_CASK_OPTS="--no-quarantine"
        if brew bundle --file="$BREWFILE"; then
            success "Brewfile packages installation succeeded"
        else
            error "Brewfile packages installation failed"
            exit 1
        fi
    fi
}

function install_pip_packages() {
    info "Installing pip packages"
    REQUIREMENTS_FILE=${DOTFILES_REPO}/pip/requirements.txt

    if pip3 install -r "$REQUIREMENTS_FILE" 1> /dev/null; then
        success "pip packages successfully installed"
    else
        error "pip packages installation failed"
        exit 1
    fi

}

function setup_symlinks() {
    info "Setting up symlinks"

    symlink "aws"           ${DOTFILES_REPO}/aws                ~/.aws

    symlink "gitconfig"     ${DOTFILES_REPO}/git/config         ~/.gitconfig
    symlink "gitignore"     ${DOTFILES_REPO}/git/gitignore      ~/.gitignore

    symlink "inputrc"       ${DOTFILES_REPO}/misc/inputrc       ~/.inputrc

    symlink "karabiner"     ${DOTFILES_REPO}/karabiner          ~/.config/karabiner

    symlink "rclone"        ${DOTFILES_REPO}/rclone             ~/.config/rclone

    symlink "screen"        ${DOTFILES_REPO}/misc/screenrc      ~/.screenrc

    symlink "ssh"           ${DOTFILES_REPO}/ssh/config         ~/.ssh/config

    symlink "sublimetext"   ${DOTFILES_REPO}/sublimetext/User   "$HOME/Library/Application Support/Sublime Text 3/Packages/User"

    symlink "zshrc"         ${DOTFILES_REPO}/zsh/zshrc          ~/.zshrc
    symlink "zsh config"    ${DOTFILES_REPO}/zsh/config         ~/.zsh

    success "Symlinks successfully setup"
}

function configure_macos_defaults() {
    info "Configuring macOS defaults"

    current_dir=$(pwd)
    cd ${DOTFILES_REPO}/macos
    if bash defaults.sh; then
        cd $current_dir
        success "macOS defaults updated successfully"
    else
        cd $current_dir
        error "macOS defaults update failed"
        exit 1
    fi
}

function update_login_items() {
    info "Updating login items"

    if osascript ${DOTFILES_REPO}/macos/login_items.applescript &> /dev/null; then
        success "Login items updated successfully "
    else
        error "Login items update failed"
        exit 1
    fi
}

function symlink() {
    application=$1
    point_to=$2
    destination=$3
    destination_dir=$(dirname "$destination")

    if test ! -e "$destination_dir"; then
        substep "Creating ${destination_dir}"
        mkdir -p "$destination_dir"
    fi
    if rm -rf "$destination" && ln -s "$point_to" "$destination"; then
        substep "Symlinking for \"${application}\" done"
    else
        error "Symlinking for \"${application}\" failed"
        exit 1
    fi
}

function pull_latest() {
    substep "Pulling latest changes in ${1} repository"
    if git -C $1 pull origin master &> /dev/null; then
        return
    else
        error "Please pull latest changes in ${1} repository manually"
    fi
}

function coloredEcho() {
    local exp="$1";
    local color="$2";
    local arrow="$3";
    if ! [[ $color =~ ^[0-9]$ ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput bold;
    tput setaf "$color";
    echo "$arrow $exp";
    tput sgr0;
}

function info() {
    coloredEcho "$1" blue "========>"
}

function substep() {
    coloredEcho "$1" magenta "===="
}

function success() {
    coloredEcho "$1" green "========>"
}

function error() {
    coloredEcho "$1" red "========>"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi
