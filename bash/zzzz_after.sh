# Load any custom after code
if [ -d $HOME/.bash.after/ ]; then
  for config_file in $(ls $HOME/.bash.after/*.sh 2>/dev/null | grep "\.sh$") ; do
    [ -n "${__YADR_DEBUG}" ] && echo sourcing $config_file
    source $config_file
  done
fi
