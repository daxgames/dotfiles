# Load any user customizations prior to load
#
if [ -d $HOME/.zsh.before/ ] ; then
  [[ ! -f $HOME/.zsh.before/env.zsh ]] && echo "# This is a starter file for you to add your settings to." >$HOME/.zsh.before/env.zsh
  for config_file in ($HOME/.zsh.before/*.zsh) ; do
    [[ -n "${__YADR_DEBUG}" ]] && echo "source $config_file"
    source $config_file
  done
fi
