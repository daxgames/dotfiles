set -o vi
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER="nvim +Man!"

if [[ -n "$(command -v brew)" ]] ; then
  [[ -f "$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]] && source "$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
fi
