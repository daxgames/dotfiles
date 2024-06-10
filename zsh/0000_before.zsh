# Load any user customizations prior to load
#
if [ -d $HOME/.zsh.before/ ]; then
  if [ "$(ls -A $HOME/.zsh.before/)" ]; then
    for config_file ($HOME/.zsh.before/*.zsh) ; do
      [[ -n "${__DEBUG_YADR}" ]] && echo "source $config_file"
      source $config_file
    done
  fi
fi
