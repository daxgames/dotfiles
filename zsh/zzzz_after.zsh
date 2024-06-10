# Load any custom after code
if [ -d $HOME/.zsh.after/ ]; then
  if [ "$(ls -A $HOME/.zsh.after/)" ]; then
    for config_file ($HOME/.zsh.after/*.zsh) ; do
      [[ -n "${__DEBUG_YADR}" ]] && echo "source $config_file"
      source $config_file
    done
  fi
fi

pathPrepend ${HOME}/bin
