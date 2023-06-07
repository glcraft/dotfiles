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

function install_brew {
    if [ "$(which curl)" == "" ]; then
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
}

# select a package manager
if [ "$(uname)" == "Darwin" ]; then
    # On macOS, install brew if it's not already installed
    if [ "$(which brew)" == "" ]; then
        install_brew
    fi
    echo "Using brew as package manager..."
    PKG_MGR="brew"
    INSTALL_PKG="$PKG_MGR install"
    echo "Updating brew..."
    $INSTALL_PKG update && $INSTALL_PKG upgrade || quit_if_failed "brew update && brew upgrade"
# On Linux...
elif $ISLINUX; then
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
    elif [ "$(which yum)" != "" ]; then
        echo "Using yum as package manager..."
        PKG_MGR="yum"
        INSTALL_PKG="sudo $PKG_MGR install"
        echo "Updating yum..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "yum update && yum upgrade"
    elif [ "$(which dnf)" != "" ]; then
        echo "Using dnf as package manager..."
        PKG_MGR="dnf"
        INSTALL_PKG="sudo $PKG_MGR install"
        echo "Updating dnf..."
        sudo $PKG_MGR update && sudo $PKG_MGR upgrade || quit_if_failed "dnf update && dnf upgrade"
    elif [ "$(which pacman)" != "" ]; then
        echo "Using pacman as package manager..."
        PKG_MGR="pacman"
        INSTALL_PKG="sudo $PKG_MGR -S"
        echo "Updating pacman..."
        sudo $PKG_MGR -Syu
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
INSTALL_PKG="sudo $INSTALL_PKG -y"

# install git
if [ "$(which git)" == "" ]; then
    echo "Installing git..."
    $INSTALL_PKG git
fi

# install paru on arch linux
if [ $ISLINUX -eq 1 ] && [ "$(which pacman)" -ne "" ] && [ "$(which paru)" -eq "" ]; then
    echo "Installing paru..."
    git clone https://aur.archlinux.org/paru.git /tmp/init/paru
    pushd /tmp/init/paru
    makepkg -si
    popd
fi
# use paru as package manager 
if [ "$(which paru)" != "" ]; then
    echo "Using paru as package manager instead..."
    PKG_MGR="paru"
    INSTALL_PKG="sudo $PKG_MGR -S"
fi

# download and install nu shell
if [ "$(which nu)" == "" ]; then
    # install brew for linux if needed
    if [ "$(which pacman)" == "" ] && [ "$(which brew)" == "" ]; then
        install_brew
    fi
    echo "Installing nu shell..."
    INSTALL=KO
    if [ "$(which pacman)" != "" ]; then
        sudo pacman -S nushell && INSTALL=OK
    elif [ "$(which brew)" != "" ]; then
        brew install nushell && INSTALL=OK
    fi
    if [ $INSTALL != OK ]; then
        echo "Unable to install nushell. Skip..."
    else
        # ask for setting nu as default shell
        echo "Do you want to set nu as your default shell? [y/N]"
        read -r SET_NU_AS_DEFAULT
        if [ "$SET_NU_AS_DEFAULT" == "y" ]; then
            echo "Setting nu as default shell..."
            sudo chsh -s "$(which nu)"
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
        if [ "$(which starship)" == "" ]; then
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
        else
            echo "Starship prompt already installed!"
        fi
        # add starship to zshrc
        cat <<EOF
# Initialize Starship
eval "$(starship init zsh)"
EOF >> ~/.zshrc
        # add starship to nu config
        cat <<EOF
# Initialize Starship
eval "$(starship init zsh)"
EOF >> $(nu -c '$nu.config-path')
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

# remove temporary directory
rm -rf /tmp/init