# Load any user customizations prior to load
#
if [ -d $HOME/.zsh.before/ ] && [ -n "$(ls $HOME/.zsh.before/ | grep "\.zsh" 2>/dev/null)" ];  then
  for config_file ($HOME/.zsh.before/*.zsh) ; do
    [[ -n "${__YADR_DEBUG}" ]] && echo "source $config_file"
    source $config_file
  done
fi
