#!/usr/bin/env bash

RED="\033[0;31m"
GREEN="\033[0;32m"
GRAPHICAL=N

# parse arguments
while (( "$#" )); do
    opt="$1"
    case $opt in
        --graphical)
            GRAPHICAL=Y
            ;;
        -h|--help)
            cat << EOF
Usage: $(basename $0) [--graphical] [-h|--help]
    --graphical                 install graphical apps (default: no)
    -h|--help                   show this help message"
EOF
            exit 0
            ;;
        *)
            echo "Invalid option: $opt"
            exit 1
            ;;
    esac
    shift
done

# quit if not in dotfile directory
if [ ! -f "setup/init.sh" ]; then
    echo "Please run this script in the dotfile directory!"
    exit 1
fi

if ! which which 1>/dev/null 2>&1; then
    echo "Install the command 'which' first!"
    exit 1
fi

# check if a program exists
function check_program {
    which $1 2>/dev/null 1>&2
}

# check if a program exists and install it if not
function check_and_install {
    for prog in $@; do
        if ! check_program $prog; then
            echo -n "Installing $prog using $PKG_MGR... "
            if $INSTALL_PKG $prog; then
                echo "\033[0;32mOK\033[0m"
            else 
                echo "$\033[0;31mKO\033[0m"
                return 1
            fi
        fi
    done
    return 0
}

function check_package {
    if check_program pacman; then
        pacman -Qs $1 >/dev/null 2>&1
    elif check_program dpkg-query; then
        dpkg-query -W $1 >/dev/null 2>&1
    elif check_program dpkg; then
        dpkg -s $1 >/dev/null 2>&1
    elif check_program rpm; then
        rpm -q $1 >/dev/null 2>&1
    elif check_program brew; then
        brew list $1 >/dev/null 2>&1
    elif check_program cargo; then
        cargo install --list | grep -E "$1 v[0-9.]+:" >/dev/null 2>&1
    else
        echo "No package manager found!"
        exit 1
    fi
}

function check_package_and_install_no_root {
    if ! check_package $1; then
        echo -n "Installing $1 using $PKG_MGR without root... "
        INSTALL_NO_ROOT=`(echo "$ISNTALL_PKG" | sed "s/sudo //g")`
        if $INSTALL_NO_ROOT $1; then
            echo "\033[0;32mOK\033[0m"
        else 
            echo "$\033[0;31mKO\033[0m"
            return 1
        fi
    fi
    return 0
}
function check_package_and_install {
    if ! check_package $1; then
        echo -n "Installing $1 using $PKG_MGR... "
        if $INSTALL_PKG $1; then
            echo "\033[0;32mOK\033[0m"
        else 
            echo "$\033[0;31mKO\033[0m"
            return 1
        fi
    fi
    return 0
}
function check_and_install_using {
    if ! check_program $2; then
        echo -n "Installing $2 using "$1"... "
        if $1 $2; then
            echo "\033[0;32mOK\033[0m"
        else 
            echo "$\033[0;31mKO\033[0m"
            return 1
        fi
    fi
    return 0
}

# grant sudo permission
if [ "$(whoami)" != "root" ]; then
    echo "Granting sudo permission..."
    sudo -v
    # keep-alive: update existing sudo time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

TMPDIR=$(mktemp -d)

[ "$(uname)" == "Darwin" ] && ISMACOS=1 || ISMACOS=0
[ "$(uname)" == "Linux" ] && ISLINUX=1 || ISLINUX=0

#function to quit the script if any command fails
function quit_if_failed {
    if [ $? -ne 0 ]; then
        echo "Failed to execute command: $1"
        exit 1
    fi
}
function download {
    if check_program wget; then
        wget -O - "$1"
    elif check_program curl; then
        curl -fsSL "$1"
    fi
}

# Select a package manager
# On MacOS...
if [ $ISMACOS -eq 1 ]; then
    # On macOS, install brew if it's not already installed
    if ! check_program brew; then
        check_and_install curl
        echo "Installing brew..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ $ISLINUX -eq 1 ]; then
            echo '# Set PATH, MANPATH, etc., for Homebrew.' >> $HOME/.profile
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $HOME/.profile
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
    echo "Using brew as package manager..."
    PKG_MGR="brew"
    INSTALL_PKG="$PKG_MGR install"
    echo "Updating brew..."
    $INSTALL_PKG update && $INSTALL_PKG upgrade || quit_if_failed "brew update && brew upgrade"
# On Linux...
elif [ $ISLINUX -eq 1 ]; then
    if check_program apt; then
        echo "Using apt as package manager..."
        PKG_MGR="apt"
        INSTALL_PKG="sudo $PKG_MGR install -y"
        echo "Updating apt..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade -y || quit_if_failed "apt update && apt upgrade"
    elif check_program apt-get; then
        echo "Using apt-get as package manager..."
        PKG_MGR="apt-get"
        INSTALL_PKG="sudo $PKG_MGR install -y"
        echo "Updating apt-get..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "apt-get update && apt-get upgrade"
    elif check_program yum; then
        echo "Using yum as package manager..."
        PKG_MGR="yum"
        INSTALL_PKG="sudo $PKG_MGR install -y"
        echo "Updating yum..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "yum update && yum upgrade"
    elif check_program dnf; then
        echo "Using dnf as package manager..."
        PKG_MGR="dnf"
        INSTALL_PKG="sudo $PKG_MGR install -y"
        echo "Updating dnf..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "dnf update && dnf upgrade"
    elif check_program pacman; then
        echo "Using pacman as package manager..."
        PKG_MGR="pacman"
        INSTALL_PKG="sudo $PKG_MGR -S --noconfirm"
        echo "Updating pacman..."
        sudo $PKG_MGR -Syu --noconfirm || quit_if_failed "pacman -Syu --noconfirm"
    elif check_program brew; then
        echo "Using brew as package manager..."
        PKG_MGR="brew"
        INSTALL_PKG="$PKG_MGR install"
        echo "Updating brew..."
        $PKG_MGR update && $PKG_MGR upgrade || quit_if_failed "brew update && brew upgrade"
    else
        echo "No package manager found!"
        exit 1
    fi
fi

#install zsh
check_and_install zsh

# install base-devel on linux
if [ $ISLINUX -eq 1 ] && ! check_program gcc; then
    if check_program pacman; then
        echo "Installing base-devel..."
        $INSTALL_PKG base-devel
    elif check_program apt || check_program apt-get; then
        echo "Installing build-essential..."
        $INSTALL_PKG build-essential
    elif check_program yum || check_program dnf; then
        echo "Installing groupinstall development tools..."
        $INSTALL_PKG groupinstall development tools
    fi
fi

# install rust
if ! check_program rustup; then
    echo "Installing rust..."
    ($INSTALL_PKG rustup && rustup toolchain add stable)|| curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s - -y
fi

# install git if not already installed
if ! check_program git; then
    echo "Installing git..."
    $INSTALL_PKG git
fi

# install paru on arch linux
if [ $ISLINUX -eq 1 ] && check_program pacman && ! check_program paru; then
    check_and_install pkg-config
    echo "Installing paru..."
    git clone https://aur.archlinux.org/paru.git "$TMPDIR/paru"
    pushd $TMPDIR/paru
    makepkg -si
    popd
fi

# use paru as package manager 
if check_program paru; then
    echo "Using paru as package manager instead..."
    PKG_MGR="paru"
    INSTALL_PKG="sudo $PKG_MGR -S --noconfirm"
fi

# download and install nu shell
check_package_and_install nushell || check_and_install_using "cargo install" nu

# install zimfw
if ! check_program zimfw; then
    echo "Installing zimfw..."
    (download https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh && zimfw install) && echo "$(echo $RED)OK" || echo "$(echo $GREEN)KO"
fi

echo -n "Installing starship prompt from starship.rs/install.sh... "
(download https://starship.rs/install.sh | sh) && echo "$(echo $RED)OK" || echo "$(echo $GREEN)KO"

# install bunch of useful tools

check_and_install bat || check_and_install_using "cargo install" bat # https://github.com/sharkdp/bat
check_package_and_install tealdeer || check_and_install_using "cargo install" tealdeer # https://github.com/dbrgn/tealdeer
check_package_and_install fd-find || check_and_install fd || check_and_install_using "cargo install" fd-find # https://github.com/sharkdp/fd
check_package_and_install ripgrep || check_and_install_using "cargo install" ripgrep # https://github.com/BurntSushi/ripgrep
check_and_install exa || check_and_install_using "cargo install" exa # https://github.com/ogham/exa
check_and_install hyperfine || check_and_install_using "cargo install" hyperfine # https://github.com/sharkdp/hyperfine
check_and_install just || check_and_install_using "cargo install" just # https://github.com/casey/just
check_package_and_install the_silver_searcher # https://github.com/ggreer/the_silver_searcher
check_and_install fzf # https://github.com/junegunn/fzf
check_package_and_install carapace-bin || check_package_and_install_no_root carapace-bin # https://github.com/rsteube/carapace-bin
check_and_install which

if ! check_program xmake; then
    curl -fsSL https://xmake.io/shget.text | bash
    [ -f ~/.xmake/profile ] && source ~/.xmake/profile && xmake update -s dev || ~/.local/bin/xmake update -s dev
fi

# install graphical apps
if [ "$GRAPHICAL" = Y ]; then
    $INSTALL_PKG discord keepassxc --needed
    # ...from the AUR
    if [ "$PKG_MGR" = "paru" ]; then
        paru --noconfirm -S microsoft-edge-stable-bin visual-studio-code-bin --needed
    fi
fi
