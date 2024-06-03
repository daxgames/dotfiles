set -o vi
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER="nvim +Man!"

command -v brew >/dev/null && source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
