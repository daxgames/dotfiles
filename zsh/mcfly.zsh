if [[ -n "$(command -v mcfly)" ]] ; then
  eval "$(mcfly init zsh)"
  export MCFLY_KEY_SCHEME=vim
  export MCFLY_FUZZY=true
  export MCFLY_RESULTS=50
fi