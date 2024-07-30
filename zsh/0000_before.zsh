# Load any user customizations prior to load
#
if [ -d $HOME/.zsh.before/ ] ; then
  for config_file in $(ls $HOME/.zsh.before/*.zsh 2>/dev/null | grep ".zsh$" ) ; do
    [[ -n "${__YADR_DEBUG}" ]] && echo "source $config_file"
    source $config_file
  done
fi
