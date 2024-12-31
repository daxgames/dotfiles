# Load any user customizations prior to load
#
if [ -d $HOME/.bash.before/ ]; then
  [[ ! -f $HOME/.bash.before/env.zsh ]] && echo "# This is a starter file for you to add your settings to." >$HOME/.bash.before/env.zsh
  for config_file in $(ls $HOME/.bash.before/*.sh 2>/dev/null | grep "\.sh$") ; do
    [ -n "${__YADR_DEBUG}" ] && echo sourcing $config_file
    source $config_file ;
  done
fi
