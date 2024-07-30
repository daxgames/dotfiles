# Load any user customizations prior to load
#
if [ -d $HOME/.zsh.before/ ] ; then
  [[ ! -f $HOME/.zsh.before/env.zsh ]] && echo "# This is a starter file for you to add your settings to." >$HOME/.zsh.before/env.zsh
  for config_file in $(ls $HOME/.zsh.before/*.zsh 2>/dev/null | grep ".zsh$" ) ; do
    [[ -n "${__YADR_DEBUG}" ]] && echo "source $config_file"
    source $config_file
  done
fi
