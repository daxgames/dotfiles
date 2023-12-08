#!/bin/sh

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing YADR for the first time"

    git_repo=$(echo ${__YADR_REPO_URL:-https://github.com/daxgames/dotfiles.git})
    git_branch=$(echo ${__YADR_REPO_BRANCH:-main})
    # git_repo=$(git ls-remote --get-url 2>/dev/null)
    # git_branch=$(git branch --show-current 2>/dev/null)

    [ -n "${DEBUG}" ] && env | grep "__YADR_"
    echo "git_repo: ${git_repo}"
    echo "git_branch: ${git_branch}"

    git clone -b ${git_branch} --depth=1 ${git_repo} "$HOME/.yadr"
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
