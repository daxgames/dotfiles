# Load any custom after code
if [ -d $HOME/.zsh.after/ ]; then
  for config_file in $(ls $HOME/.zsh.after/*.zsh 2>/dev/null) ; do
    [[ -n "${__YADR_DEBUG}" ]] && echo "source $config_file"
    source $config_file
  done
fi

pathPrepend ${HOME}/bin
