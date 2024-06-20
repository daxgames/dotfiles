# Load any custom after code
if [ -d $HOME/.zsh.after/ ]; then
  for config_file in $(find $HOME/.zsh.after/ -name '*.zsh' -type f) ; do
    [[ -n "${__YADR_DEBUG}" ]] && echo "source $config_file"
    source $config_file
  done
fi

pathPrepend ${HOME}/bin
