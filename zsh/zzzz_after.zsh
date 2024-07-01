# Load any custom after code
if [ -d $HOME/.zsh.after/ ] && [ -n "$(ls $HOME/.zsh.after/ | grep "\.zsh" 2>/dev/null)" ];  then
  for config_file ($HOME/.zsh.after/*.zsh) ; do
    [[ -n "${__YADR_DEBUG}" ]] && echo "source $config_file"
    source $config_file
  done
fi

pathPrepend ${HOME}/bin
