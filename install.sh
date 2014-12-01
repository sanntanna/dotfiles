#!/usr/bin/env bash

libs=(apps brew dotfiles fonts npm quicklook ruby sublime)

# Help text
source ./lib/help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    run_help
    exit
fi
source ./lib/utils

# Source the necessary files and helper scripts
for i in "${libs[@]}"; do
    source ./lib/$i
done

if array_contains "$1" "${libs[@]}"; then

    seek_confirmation "Do you want to install $1"

    if is_confirmed; then
        run_$1
    fi
    exit
fi

sudo -v
sudo chown $USER /usr/local/

git pull


# Before relying on Homebrew, check that packages can be compiled
if ! type_exists 'gcc'; then
    e_error "The XCode Command Line Tools must be installed first."
    printf "  run 'xcode-select --install' and follow the instrucctions\n"
    printf "  Then run this setup script again.\n"
    exit 1
fi

#  _____
# /__  /
#   / /
#  / /__
# /____/
#

if [ ! -f /usr/local/z/z.sh ]; then

    e_process "Installing z"

    # https://github.com/rupa/z
    # z, oh how i love you
    mkdir /usr/local/z
    git clone https://github.com/rupa/z.git /usr/local/z
    chmod +x /usr/local/z/z.sh
    # also consider moving over your current .z file if possible. it's painful to rebuild :)
fi

#     __  __                     __
#    / / / /___  ____ ___  ___  / /_  ________ _      __
#   / /_/ / __ \/ __ `__ \/ _ \/ __ \/ ___/ _ \ | /| / /
#  / __  / /_/ / / / / / /  __/ /_/ / /  /  __/ |/ |/ /
# /_/ /_/\____/_/ /_/ /_/\___/_.___/_/   \___/|__/|__/


# Check for Homebrew
if ! type_exists 'brew'; then
    e_process "Installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    e_process "Installing Homebrew packages"
    run_brew
fi

#     ____        __
#    / __ \__  __/ /_  __  __
#   / /_/ / / / / __ \/ / / /
#  / _, _/ /_/ / /_/ / /_/ /
# /_/ |_|\__,_/_.___/\__, /
#                   /____/

# Check for rvm
if ! type_exists 'rvm'; then

    e_process "Installing RVM..."
    curl -L https://get.rvm.io | bash -s stable --ruby

    e_process "Installing Gems"
    run_ruby
fi

#     _   ______  __  ___
#    / | / / __ \/  |/  /
#   /  |/ / /_/ / /|_/ /
#  / /|  / ____/ /  / /
# /_/ |_/_/   /_/  /_/
#

e_process "Installing NPM Packages"
run_npm

#    ______            __
#   /_  __/___  ____  / /____
#    / / / __ \/ __ \/ / ___/
#   / / / /_/ / /_/ / (__  )
#  /_/  \____/\____/_/____/
#

e_process "Installing other tools"

bash < <( curl https://raw.github.com/jamiew/git-friendly/master/install.sh)
sudo easy_install Pygments



e_success "All packages have been installed"

#     ____             __
#    / __ )____ ______/ /_
#   / __  / __ `/ ___/ __ \
#  / /_/ / /_/ (__  ) / / /
# /_____/\__,_/____/_/ /_/
#

if [ -f /usr/local/bin/bash ]; then
    if grep -Fxq "/usr/local/bin/bash" /etc/shells; then
        echo ""
    else
        sudo echo -e '/usr/local/bin/bash' >> /etc/shells
    fi

    if [[ $SHELL != '/usr/local/bin/bash' ]]; then
    	chsh -s /usr/local/bin/bash
	fi
fi

#        __      __  _____ __
#   ____/ /___  / /_/ __(_) /__  _____
#  / __  / __ \/ __/ /_/ / / _ \/ ___/
# / /_/ / /_/ / /_/ __/ / /  __(__  )
# \__,_/\____/\__/_/ /_/_/\___/____/


# Ask before potentially overwriting files
seek_confirmation "Overwrite your existing dotfiles"

if is_confirmed; then
    # Symlink all necessary files

    run_dotfiles

    e_success "All files have been symlinked"

else
    e_error "This step is required.  When you're ready, run this script to start up again"
fi

#    ____  _____    _  __    ___
#   / __ \/ ___/   | |/ /   /   |  ____  ____  _____
#  / / / /\__ \    |   /   / /| | / __ \/ __ \/ ___/
# / /_/ /___/ /   /   |   / ___ |/ /_/ / /_/ (__  )
# \____//____/   /_/|_|  /_/  |_/ .___/ .___/____/
#                              /_/   /_/

# Ask installing OS X Applications?
seek_confirmation "Do you want to install Mac OS X Apps and stuff"

if is_confirmed; then

    e_process "Installing Mac OS X Applications"
    run_apps

    e_process "Installing Mac OS X fonts"
    run_fonts

    e_process "Installing Mac OS X Quick Look plugins for developers"
    run_quicklook

    e_process "Installing ST2 plugins"
    #run_sublime

    e_success "All Mac OS X Applications have been installed"

    e_warning "Please consider using cask commands for Updating/Upgrading or Uninstalling a Mac OS X Application"
fi

e_success "Your MAC is ready to rock!"