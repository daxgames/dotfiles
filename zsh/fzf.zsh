if [[ -n "$(command -v fzf)" ]] ; then
  alias -g F='| fzf'
  alias nvf='nvim $(fzf --preview "bat --color=always --style=numbers --line-range=:500 {}")'
  alias vf='vim $(fzf --preview "bat --color=always --style=numbers --line-range=:500 {}")'
  alias cf='code -w $(fzf --preview "bat --color=always --style=numbers --line-range=:500 {}")'
  alias fzfp='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

  if [[ -n "$(command -v brew)" ]] ; then
    # Auto-completion
    # ---------------
    if [[ -n "$(command -v brew)" ]] && [[ $- == *i* ]] ; then
      source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" 2> /dev/null
    fi

    # Key bindings
    # ------------
    if [[ -n "$(command -v brew)" ]] ; then
      [[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]] && source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
    fi
  else
    source <(fzf --zsh)
  fi

  # fasd & fzf change directory - jump using `fasd` if given argument, filter output of `fasd` using `fzf` else
  [[ -n "$(alias z)" ]] && unalias z #removing fasd's alias for z first

  function z() {
    [ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
  }

  if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
    # Colors below are gruvbox
    # export FZF_DEFAULT_OPTS='
    #   -m --height 50% --border
    #   --color fg:#ebdbb2,bg:#424242,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
    #   --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
    # '
  fi
fi

