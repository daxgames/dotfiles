#!/bin/sh

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing YADR for the first time"
    git clone -b main --depth=1 https://github.com/daxgames/dotfiles.git "$HOME/.yadr"
    cd "$HOME/.yadr"
    [ "$1" = "ask" ] && export ASK="true"

    PLATFORM=$(uname)
    if [ "${PLATFORM}" = "Linux" ] ; then
        PLATFORM_FAMILY=$(lsb_release -is | tr [A-Z] [a-z])
        PLATFORM_VERSION=$(lsb_release -ir)

        if [ "${PLATFORM_FAMILY}" = "ubuntu" ] ; then
            sudo apt install -y rake zsh pip
            pip install pynvim
        fi
    elif [ "${PLATFORM}" = "Darwin" ] ; then
        PLATFORM_FAMILY=$(echo ${PLATFORM} | tr [A-Z] [a-z])
    fi
    env | grep PLATFORM_
    rake install
else
    echo "YADR is already installed"
fi
