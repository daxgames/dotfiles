#!/usr/bin/env bash

__YADR_SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export __YADR_SCRIPT_DIR

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing daxgames's YADR for the first time"

    git_repo="${__YADR_REPO_URL:-https://github.com/daxgames/dotfiles.git}"
    git_branch="${__YADR_REPO_BRANCH:-main}"

    if [ -n "${__YADR_DEBUG}" ] ; then
      git_repo=$(git ls-remote --get-url 2>/dev/null)
      git_branch=$(git branch --show-current)
    fi

    [ -n "${__YADR_DEBUG}" ] && env | grep "__YADR_"
    echo "git_repo: ${git_repo}"
    echo "git_branch: ${git_branch}"

    echo git clone -b "${git_branch}" --depth=1 "${git_repo}" "$HOME/.yadr"
    git clone -b "${git_branch}" --depth=1 "${git_repo}" "$HOME/.yadr"
    cd "$HOME/.yadr" || exit 1
    [ "$1" = "ask" ] && export ASK="true"

    OS=$(uname)
    if [[ "${OS}" =~ (MSYS) ]] || [[ "${OS}" =~ (MINGW) ]]; then
        PLATFORM=windows
        PLATFORM_FAMILY=windows
 
        # MSYS use Windows native symlinks
        MSYS=winsymlinks:nativestict
        CYGWIN=winsymlinks:nativestrict
        export MSYS CYGWIN
        export PLATFORM PLATFORM_FAMILY
        [ -z "${__YADR_DEBUG}" ] && env | grep PLATFORM | sort
    elif [ "${OS}" = "Linux" ] ; then
        if [ -f /etc/os-release ] ; then
            echo "Determining Linux OS using '/etc/os-release'..."
            PLATFORM=$(grep -i ^id= /etc/os-release | cut -d = -f2 | sed 's/"//g')
            PLATFORM_FAMILY=$(grep -i ^id_like= /etc/os-release | cut -d = -f2 | sed 's/"//g')
            PLATFORM_VERSION=$(grep -i ^version_id= /etc/os-release | cut -d = -f2 | sed 's/"//g')

            [ "${PLATFORM}" = "arch" ] && PLATFORM_FAMILY=arch
            [ "${PLATFORM}" = "centos" ] && PLATFORM_FAMILY=rhel
            [ "${PLATFORM}" = "fedora" ] && PLATFORM_FAMILY=rhel
            [ "${PLATFORM}" = "debian" ] && PLATFORM_FAMILY=debian
        elif [ -f /etc/redhat-release ] ; then
            PLATFORM=redhat
            PLATFORM_FAMILY=rhel
        fi

        export PLATFORM PLATFORM_FAMILY PLATFORM_VERSION
        [ -z "${__YADR_DEBUG}" ] && env | grep PLATFORM | sort

    elif [ "${OS}" = "Darwin" ] ; then
        PLATFORM_FAMILY="$(echo "${PLATFORM}" | tr  '[:upper:]' '[:lower:]')"
    fi

    if [ -z "$(command -v rake)" ] ; then
        echo "Installing YADR Pre-Reqs in '${PLATFORM_FAMILY}'..."
        if [ "${PLATFORM_FAMILY}" = "windows" ] ; then
            if [ ! -f "${__YADR_SCRIPT_DIR}/bin/install-windows-pre.ps1" ]; then
                echo "ERROR: '${__YADR_SCRIPT_DIR}/bin/install-windows-pre.ps1' not found!"
                curl -o "${TEMP}/install-windows-pre.ps1" https://raw.githubusercontent.com/daxgames/dotfiles/main/bin/install-windows-pre.ps1
                __YADR_INSTALLER_WINDWS_PRE="${TEMP}/install-windows-pre.ps1"
            else
                __YADR_INSTALLER_WINDWS_PRE="${__YADR_SCRIPT_DIR}/bin/install-windows-pre.ps1"
            fi

            echo "Running '${__YADR_INSTALLER_WINDWS_PRE}'..."
            powershell -NoProfile -NoLogo -Command "& {Start-Process -FilePath powershell -argumentlist '-f ${__YADR_INSTALLER_WINDWS_PRE}' -Wait}"
        elif [ "${PLATFORM_FAMILY}" = "arch" ] ; then
            $(command -v sudo) pacman -Syu
            $(command -v sudo) pacman -S ruby-rake zip
        elif [ "${PLATFORM_FAMILY}" = "debian" ]; then
            $(command -v sudo) apt-get update -y
            $(command -v sudo) apt-get install -y rake ruby-dev zip
        elif [ "${PLATFORM_FAMILY}" = "rhel" ] ; then
            [ "${PLATFORM_VERSION}" -lt 8 ] && PACKAGE_MANAGER=yum
            [ "${PLATFORM_VERSION}" -gt 7 ] && PACKAGE_MANAGER=dnf
            $(command -v sudo) "${PACKAGE_MANAGER}" update -y
            $(command -v sudo) "${PACKAGE_MANAGER}" groups install -y "Development Tools"
            $(command -v sudo) "${PACKAGE_MANAGER}" install -y ruby-devel rubygem-rake zip
        fi
    fi

    # Enable vim/nvim persistent undo
    if [[ -d "$HOME/.vim" ]]; then
        mkdir -p "$HOME/.vim/backups" > /dev/null 2>&1
    fi

    if [[ -d "$HOME/.config/nvim" ]]; then
        mkdir -p "$HOME/.config/nvim/backups" > /dev/null 2>&1
    fi

    if [ "${OS}" = "Linux" ] ; then
        if [ -z "$(command -v nvm)" ] && [ -z "$(command -v npm)" ] ; then
            echo "Installing 'Node Version Manager and Node'..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
            export NVM_DIR
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
        fi
    fi

    # until rake is in the path loop and wait
    until [ -n "$(command -v rake)" ] ; do
        echo "Waiting '5' seconds for rake to be in the path..."
        sleep 5
        for var in $(reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /s | grep REG_SZ | awk '{print $1}' | sed 's/\\//g'); do
            export $var="$(reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v $var | grep REG_SZ | awk '{print $3}')"
        done
    rake install
else
    echo "YADR is already installed"
    current_dir=$(pwd)
    cd "$HOME/.yadr" >>/dev/null 2>&1 || exit 1
    git pull --rebase && rake update
    cd "$current_dir" >>/dev/null 2>&1 || exit 1
fi
