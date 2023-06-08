#!/usr/bin/env bash

PROMPTER="starship"

# parse arguments
for opt in "$@"
do
    case $opt in
        -p|--powerline10k)
            PROMPTER="powerline10k"
            ;;
        -n|--no-prompter)
            PROMPTER="none"
            ;;
        -h|--help)
            echo "Usage: $0 [-p|--powerline10k] [-h|--help] [-n|--no-prompter]"
            echo "  -p|--powerline10k:  use powerline10k as prompter"
            echo "  -n|--no-prompter:   do not use any prompter"
            echo "  -h|--help:          show this help message"
            exit 0
            ;;
        *)
            echo "Invalid option: $opt"
            exit 1
            ;;
    esac
done

# quit if not in dotfile directory
if [ ! -f "setup/init.sh" ]; then
    echo "Please run this script in the dotfile directory!"
    exit 1
fi

# grant sudo permission
if [ "$(whoami)" != "root" ]; then
    echo "Granting sudo permission..."
    sudo -v
    # keep-alive: update existing sudo time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# Create a temporary directory to store the downloaded files
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
    if [ "$(which wget)" != "" ]; then
        wget -O - "$1"
    elif [ "$(which curl)" != "" ]; then
        curl -fsSL "$1"
    fi
}

# Select a package manager
# On MacOS...
if [ $ISMACOS -eq 1 ]; then
    # On macOS, install brew if it's not already installed
    if [ "$(which brew)" = "" ]; then
        if [ "$(which curl)" = "" ]; then
        echo "Installing curl..."
        $INSTALL_PKG curl
    fi
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
    if [ "$(which apt)" != "" ]; then
        echo "Using apt as package manager..."
        PKG_MGR="apt"
        INSTALL_PKG="sudo $PKG_MGR install -y"
        echo "Updating apt..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade -y || quit_if_failed "apt update && apt upgrade"
    elif [ "$(which apt-get)" != "" ]; then
        echo "Using apt-get as package manager..."
        PKG_MGR="apt-get"
        INSTALL_PKG="sudo $PKG_MGR install -y"
        echo "Updating apt-get..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "apt-get update && apt-get upgrade"
    elif [ "$(which yum)" != "" ]; then
        echo "Using yum as package manager..."
        PKG_MGR="yum"
        INSTALL_PKG="sudo $PKG_MGR install -y"
        echo "Updating yum..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "yum update && yum upgrade"
    elif [ "$(which dnf)" != "" ]; then
        echo "Using dnf as package manager..."
        PKG_MGR="dnf"
        INSTALL_PKG="sudo $PKG_MGR install -y"
        echo "Updating dnf..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "dnf update && dnf upgrade"
    elif [ "$(which pacman)" != "" ]; then
        echo "Using pacman as package manager..."
        PKG_MGR="pacman"
        INSTALL_PKG="sudo $PKG_MGR -S --noconfirm"
        echo "Updating pacman..."
        sudo $PKG_MGR -Syu --noconfirm || quit_if_failed "pacman -Syu --noconfirm"
    elif [ "$(which brew)" != "" ]; then
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
if [ "$(which zsh)" = "" ]; then
    echo "Installing zsh..."
    $INSTALL_PKG zsh
fi

# install base-devel on linux
if [ $ISLINUX -eq 1 ]; then
    if [ "$(which pacman)" != "" ]; then
        echo "Installing base-devel..."
        $INSTALL_PKG base-devel
    elif [ "$(which apt)" != "" ] || [ "$(which apt-get)" != "" ]; then
        echo "Installing build-essential..."
        $INSTALL_PKG build-essential
    elif [ "$(which yum)" != "" ] || [ "$(which dnf)" != "" ]; then
        echo "Installing groupinstall development tools..."
        $INSTALL_PKG groupinstall development tools
    fi
fi

# install rust
if [ "$(which rustup)" = "" ]; then
    echo "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s - -y
fi

# install git if not already installed
if [ "$(which git)" = "" ]; then
    echo "Installing git..."
    $INSTALL_PKG git
fi

# install paru on arch linux
if [ $ISLINUX -eq 1 ] && [ "$(which pacman)" != "" ] && [ "$(which paru)" = "" ]; then
    echo "Installing paru..."
    git clone https://aur.archlinux.org/paru.git "$TMPDIR/paru"
    pushd $TMPDIR/paru
    makepkg -si
    popd
fi

# use paru as package manager 
if [ "$(which paru)" != "" ]; then
    echo "Using paru as package manager instead..."
    PKG_MGR="paru"
    INSTALL_PKG="sudo $PKG_MGR -S --noconfirm"
fi

# download and install nu shell
if [ "$(which nu)" = "" ]; then
    echo -n "Installing nu shell... "
    INSTALL=KO
    if [ "$(which pacman)" != "" ]; then
        $INSTALL_PKG nushell && INSTALL=OK
    else
        cargo install nu && INSTALL=OK
    fi
    echo $INSTALL
    if [ "$INSTALL" = "OK" ]; then
        # ask for setting nu as default shell
        echo "Do you want to set nu as your default shell? [y/N]"
        read -r SET_NU_AS_DEFAULT
        if [ "$SET_NU_AS_DEFAULT" = "y" ]; then
            echo -n "Setting nu as default shell..."
            sudo chsh -s "$(which nu)" && echo OK || echo KO
        fi
    fi
fi

# install dot files and folders
echo "Installing dot files and folders..."
find . -maxdepth 1 -path "./.*" -not -name ".git" -exec cp -r '{}' ~/ \;


case $PROMPTER in
    starship)
        if [ "$(which starship)" = "" ]; then
            echo "Installing starship prompt..."
            if [ "$(which pacman)" != "" ] || [ "$(which paru)" != "" ]; then
                $INSTALL_PKG starship
            elif [ "$(which dnf)" != "" ]; then
                dnf copr enable atim/starship
                dnf install starship
            elif [ "$(which brew)" != "" ]; then
                $INSTALL_PKG starship
            else
                echo "Installing starship prompt from starship.rs/install.sh..."
                download https://starship.rs/install.sh | sh
            fi
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
