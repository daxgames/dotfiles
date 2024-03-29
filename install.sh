#!/bin/sh

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing YADR for the first time"

    git_repo=$(echo ${__YADR_REPO_URL:-https://github.com/maximus-codeshuttle/dotfiles.git})
    git_branch=$(echo ${__YADR_REPO_BRANCH:-main})

    if [ -n "${__YADR_DEBUG}" ] ; then
      git_repo=$(git ls-remote --get-url 2>/dev/null)
      git_branch=$(git branch --show-current)
    fi

    [ -n "${DEBUG}" ] && env | grep "__YADR_"
    echo "git_repo: ${git_repo}"
    echo "git_branch: ${git_branch}"

    echo git clone -b ${git_branch} --depth=1 ${git_repo} "$HOME/.yadr"
    git clone -b ${git_branch} --depth=1 ${git_repo} "$HOME/.yadr"
    cd "$HOME/.yadr"
    [ "$1" = "ask" ] && export ASK="true"

    OS=$(uname)
    if [ "${OS}" = "Linux" ] ; then
        if [ -f /etc/os-release ] ; then
            echo "Determining Linux OS using '/etc/os-release'..."
            PLATFORM=$(cat /etc/os-release | grep -i ^id= | cut -d = -f2 | sed 's/"//g')
            PLATFORM_FAMILY=$(cat /etc/os-release | grep -i ^id_like= | cut -d = -f2 | sed 's/"//g')
            PLATFORM_VERSION=$(cat /etc/os-release | grep -i ^version_id= | cut -d = -f2 | sed 's/"//g')
            echo "PLATFORM: '${PLATFORM}'"

            [ "${PLATFORM}" = "centos" ] && PLATFORM_FAMILY=rhel
            [ "${PLATFORM}" = "fedora" ] && PLATFORM_FAMILY=rhel
            [ "${PLATFORM}" = "debian" ] && PLATFORM_FAMILY=debian
        elif [ -f /etc/redhat-release ] ; then
            PLATFORM=redhat
            PLATFORM_FAMILY=rhel
        fi

        export PLATFORM PLATFORM_FAMILY PLATFORM_VERSION
        [ -z "${__YADR_DEBUG}" ] && env | grep PLATFORM | sort

        if [ -z "$(command -v rake)" ] ; then
            echo "Installing 'rake' in '${PLATFORM_FAMILY}'..."
            if [ "${PLATFORM_FAMILY}" = "debian" ]; then
                `which sudo 2>/dev/null` apt install -y rake
            elif [ "${PLATFORM_FAMILY}" = "rhel" ] ; then
                [ "${PLATFORM_VERSION}" -lt 8 ] && `which sudo 2>/dev/null` yum install -y rubygem-rake
                [ "${PLATFORM_VERSION}" -gt 7 ] && `which sudo 2>/dev/null` dnf install -y rubygem-rake
            fi
        fi
    fi

    rake install
else
    echo "YADR is already installed"
    cd ~/.yadr
    git pull --rebase
    rake update
fi
