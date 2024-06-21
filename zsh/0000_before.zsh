# Load any user customizations prior to load
#
if [ -d $HOME/.zsh.before/ ]; then
  for config_file in $($HOME/.zsh.before/ 2>/dev/null) ; do
    [[ -n "${__YADR_DEBUG}" ]] && echo "source $config_file"
    source $config_file
  done
fi
