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
    if [ "$(which wget)" -ne "" ]; then
        wget -O - "$1"
    elif [ "$(which curl)" -ne "" ]; then
        curl -fsSL "$1"
    fi
}

# Select a package manager
# On MacOS...
if [ $ISMACOS -eq 1 ]; then
    # On macOS, install brew if it's not already installed
    if [ "$(which brew)" -eq "" ]; then
        if [ "$(which curl)" -eq "" ]; then
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
elif $ISLINUX; then
    if [ "$(which apt)" -ne "" ]; then
        echo "Using apt as package manager..."
        PKG_MGR="apt"
        INSTALL_PKG="sudo $PKG_MGR install"
        echo "Updating apt..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade -y || quit_if_failed "apt update && apt upgrade"
    elif [ "$(which apt-get)" != "" ]; then
        echo "Using apt-get as package manager..."
        PKG_MGR="apt-get"
        INSTALL_PKG="sudo $PKG_MGR install"
        echo "Updating apt-get..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "apt-get update && apt-get upgrade"
    elif [ "$(which yum)" -ne "" ]; then
        echo "Using yum as package manager..."
        PKG_MGR="yum"
        INSTALL_PKG="sudo $PKG_MGR install"
        echo "Updating yum..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "yum update && yum upgrade"
    elif [ "$(which dnf)" -ne "" ]; then
        echo "Using dnf as package manager..."
        PKG_MGR="dnf"
        INSTALL_PKG="sudo $PKG_MGR install"
        echo "Updating dnf..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "dnf update && dnf upgrade"
    elif [ "$(which pacman)" -ne "" ]; then
        echo "Using pacman as package manager..."
        PKG_MGR="pacman"
        INSTALL_PKG="sudo $PKG_MGR -S"
        echo "Updating pacman..."
        sudo $PKG_MGR -Syu
    elif [ "$(which brew)" -ne "" ]; then
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
INSTALL_PKG="sudo $INSTALL_PKG -y"

#install zsh
if [ "$(which zsh)" -eq "" ]; then
    echo "Installing zsh..."
    $INSTALL_PKG zsh
fi

# install base-devel on linux
if [ $ISLINUX -eq 1 ]
    if [ "$(which pacman)" -ne "" ]; then
        echo "Installing base-devel..."
        $INSTALL_PKG base-devel
    elif [ "$(which apt)" -ne "" ] || [ "$(which apt-get)" != "" ]; then
        echo "Installing build-essential..."
        $INSTALL_PKG build-essential
    elif [ "$(which yum)" -ne "" ] || [ "$(which dnf)" -ne "" ]; then
        echo "Installing groupinstall development tools..."
        $INSTALL_PKG groupinstall development tools
    fi
fi

# install rust
if [ "$(which rustup)" -eq "" ]; then
    echo "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s - -y
fi

# install git
if [ "$(which git)" -eq "" ]; then
    echo "Installing git..."
    $INSTALL_PKG git
fi

# install paru on arch linux
if [ $ISLINUX -eq 1 ] && [ "$(which pacman)" -ne "" ] && [ "$(which paru)" -eq "" ]; then
    echo "Installing paru..."
    git clone https://aur.archlinux.org/paru.git "$TMPDIR/paru"
    pushd $TMPDIR/paru
    makepkg -si
    popd
fi

# use paru as package manager 
if [ "$(which paru)" -ne "" ]; then
    echo "Using paru as package manager instead..."
    PKG_MGR="paru"
    INSTALL_PKG="sudo $PKG_MGR -S"
fi

# download and install nu shell
if [ "$(which nu)" -eq "" ]; then
    echo -n "Installing nu shell... "
    INSTALL=KO
    if [ "$(which pacman)" -ne "" ]; then
        sudo pacman -S nushell && INSTALL=OK
    else
        cargo install nu && INSTALL=OK
    fi
    echo $INSTALL
    if [ $INSTALL -eq OK ]; then
        # ask for setting nu as default shell
        echo "Do you want to set nu as your default shell? [y/N]"
        read -r SET_NU_AS_DEFAULT
        if [ "$SET_NU_AS_DEFAULT" == "y" ]; then
            echo -n "Setting nu as default shell..."
            sudo chsh -s "$(which nu)" && echo OK || echo KO
        fi
    fi
fi

# install dot files and folders
echo "Installing dot files and folders..."
cp -r .cache .cargo .config .zshrc  ~/

#ask for starship prompt or powerlevel10k
echo "Which prompt do you want to install ?"
echo "- starship        [1, default]"
echo "- powerlevel10k   [2]"
echo "- none            [0]"
read -r PROMPT
case $PROMPT in
    1|*)
        if [ "$(which starship)" -eq "" ]; then
            echo "Installing starship prompt..."
            if [ "$(which pacman)" -ne "" ] || [ "$(which paru)" -ne "" ]; then
                $INSTALL_PKG starship
            elif [ "$(which dnf)" -ne "" ]; then
                dnf copr enable atim/starship
                dnf install starship
            elif [ "$(which brew)" -ne "" ]; then
                $INSTALL_PKG starship
            else
                echo "Installing starship prompt from starship.rs/install.sh..."
                download https://starship.rs/install.sh | sh
            fi
        else
            echo "Starship prompt already installed!"
        fi
        ;;
    2)
        echo "Installing zimfw..."
        download https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
        echo "Installing powerlevel10k..."
        cat << EOF
# Use powerlevel10k theme
zmodule romkatv/powerlevel10k --use degit
EOF >> ~/.zimrc
        zimfw install
                cat <<EOF
# To customize prompt, run `p10k configure` or edit ~/.config/.p10k.zsh.
[[ ! -f ~/.config/.p10k.zsh ]] || source ~/.config/.p10k.zsh
EOF >> ~/.zshrc
        ;;
    0)
        echo "Skipping prompt installation..."
        ;;
esac
