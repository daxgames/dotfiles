# Load any custom after code
if [ -d $HOME/.bash.after/ ]; then
  [[ ! -f $HOME/.bash.after/env.sh ]] && echo "# This is a starter file for you to add your settings to." >$HOME/.bash.after/env.sh
  for config_file in $(ls $HOME/.bash.after/*.sh 2>/dev/null | grep "\.sh$") ; do
    [ -n "${__YADR_DEBUG}" ] && echo sourcing $config_file
    source $config_file
  done
fi
