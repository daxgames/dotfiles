# Load any user customizations prior to load
#
if [ -d $HOME/.bash.before/ ]; then
  for config_file in $(ls $HOME/.bash.before/*.sh 2>/dev/null | grep "\.sh$") ; do
    [ -n "${__YADR_DEBUG}" ] && echo sourcing $config_file
    source $config_file ;
  done
fi
