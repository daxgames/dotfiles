@echo off

export install_zsh=n

[[ ! -d ~/.bash-git-prompt ]] && git clone https://github.com/magicmonty/bash-git-prompt.git ~/.git-bash-prompt
[[ ! -d ~/.bashrc.before ]] && mkdir ~/.bashrc.before
[[ ! -d ~/.bashrc.after ]] && mkdir ~/.bashrc.after

if not exist "%USERPROFILE%\.yadr" (
    echo "Installing YADR for the first time"
    git clone -b main --depth=1 https://github.com/daxgames/dotfiles.git "%USERPROFILE%\.yadr"
    cd "%USERPROFILE%\.yadr"
    if "%~1" equ "ask" ( set ASK="true")
    rake install
) else (
    echo "YADR is already installed"
)
