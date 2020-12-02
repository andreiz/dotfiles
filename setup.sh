#!/usr/bin/env bash

main() {
    ask_for_sudo
    install_xcode_command_line_tools
    clone_dotfiles_repo
    install_homebrew
}

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
        url=https://github.com/sam-hosseini/dotfiles.git
        if git clone "$url" $DOTFILES_REPO && \
           git -C $DOTFILES_REPO remote set-url origin git@github.com:sam-hosseini/dotfiles.git; then
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

function coloredEcho() {
    local exp="$1";
    local color="$2";
    local arrow="$3";
    if ! [[ $color =~ '^[0-9]$' ]] ; then
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