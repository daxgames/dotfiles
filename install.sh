#!/bin/sh

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing daxgames's YADR for the first time"
    git clone -b nvim_2023_fix --depth=1 https://github.com/daxgames/dotfiles.git "$HOME/.yadr"
    cd "$HOME/.yadr"
    [ "$1" = "ask" ] && export ASK="true"

    OS=$(uname)
    if [ "${PLATFORM}" = "Linux" ] ; then
        PLATFORM_FAMILY=rhel
        if [ $(command -v lsb_release) ] ; then
            PLATFORM=$(lsb_release -is | tr [A-Z] [a-z])
            PLATFORM_FAMILY=$(lsb_release -is | tr [A-Z] [a-z])
            PLATFORM_VERSION=$(lsb_release -rs)

            [ "${PLATFORM}" = "centos" ] && PLATFORM_FAMILY=rhel
        elif [ -f /etc/redhat-release ] ; then
            PLATFORM=redhat
            PLATFORM_FAMILY=rhel
        fi

        if [ ! $(command -v rake) ] ; then
            if [ "${PLATFORM_FAMILY}" = "ubuntu" ] ; then
                sudo apt install -y rake
            elif [ "${PLATFORM_FAMILY}" = "rhel" ] ; then
                sudo yum install -y rake
            fi
        fi
    elif [ "${PLATFORM}" = "Darwin" ] ; then
        PLATFORM_FAMILY=$(echo ${PLATFORM} | tr [A-Z] [a-z])
    fi

    rake install
else
    echo "YADR is already installed"
fi
