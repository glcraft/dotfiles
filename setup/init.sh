#!/usr/bin/env bash

PROMPTER="starship"
RED="\033[0;31m"
GREEN="\033[0;32m"
GRAPHICAL=N

# parse arguments
while (( "$#" )); do
    opt="$1"
    case $opt in
        -p|--prompter)
            PROMPTER="$2"
            shift
            ;;
        --graphical)
            GRAPHICAL=Y
            ;;
        -h|--help)
            cat << EOF
Usage: $(basename $0) [-p|--prompter <prompt>] [-n|--no-prompter] [-h|--help]
    -p|--prompter <prompt>      use powerline10k as prompter
                                possible: powerline10k, starship, none
                                default: starship
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

# check if a program exists
function check_program {
    [ "$(which $1 2>/dev/null)" != "" ]
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

function check_package_and_install {
    ALREADY_INSTALLED=KO
    if [ "$PKG_MGR" = "pacman" ] || [ "$PKG_MGR" = "paru" ]; then
        if pacman -Qs $1 >/dev/null 2>&1 ; then
            ALREADY_INSTALLED=OK
        fi
    # elif [ "$PKG_MGR" = "apt" ]; then
    #     if dpkg -s $1 > /dev/null ; then
    #         ALREADY_INSTALLED=OK
    #     fi
    # elif [ "$PKG_MGR" = "dnf" ]; then
    #     if dnf list installed $1 > /dev/null ; then
    #         ALREADY_INSTALLED=OK
    #     fi
    # elif [ "$PKG_MGR" = "yum" ]; then
    #     if yum list installed $1 > /dev/null ; then
    #         ALREADY_INSTALLED=OK
    #     fi
    fi
    if [ "$ALREADY_INSTALLED" = "KO" ]; then
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
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s - -y
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

# install dot files and folders
echo "Installing dot files and folders..."
find . -maxdepth 1 -path "./.*" -not -name ".git" -exec cp -r '{}' ~/ \;

case $PROMPTER in
    starship)
        if ! check_and_install starship; then
            echo -n "Installing starship prompt from starship.rs/install.sh... "
            (download https://starship.rs/install.sh | sh) && echo "$(echo $RED)OK" || echo "$(echo $GREEN)KO"
        fi
        ;;
    powerlevel10k)
        echo "Installing zimfw..."
        download https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
        echo "Installing powerlevel10k..."
        cat << EOF >> ~/.zimrc
# Use powerlevel10k theme
zmodule romkatv/powerlevel10k --use degit
EOF 
        zimfw install
        cat << EOF >> ~/.zshrc
# To customize prompt, run `p10k configure` or edit ~/.config/.p10k.zsh.
[[ ! -f ~/.config/.p10k.zsh ]] || source ~/.config/.p10k.zsh
EOF
        ;;
    none)
        echo "Skipping prompt installation..."
        ;;
    *)
        echo "Unknown prompter $PROMPTER!"
        exit 1
        ;;
esac

# install bunch of useful tools
if check_program pacman || check_program paru; then
    $INSTALL_PKG bat just hyperfine fd the_silver_searcher lsd --needed

elif check_program apt || check_program apt-get; then
    $INSTALL_PKG bat fd-find the_silver_searcher --needed
    cargo install lsd hyperfine
    if check_program makedeb; then
        git clone 'https://mpr.makedeb.org/just' "$TMPDIR/just"
        pushd "$TMPDIR/just"
        makedeb -si
    else
        cargo install just
    fi
    popd

fi
if ! check_program xmake; then
    curl -fsSL https://xmake.io/shget.text | bash
    xmake update -s dev
fi

# install graphical apps
if [ "$GRAPHICAL" = Y ]; then
    $INSTALL_PKG discord keepassxc --needed
    # ...from the AUR
    if [ "$PKG_MGR" = "paru" ]; then
        paru --noconfirm -S microsoft-edge-stable-bin visual-studio-code-bin --needed
    fi
fi
