# Load any user customizations prior to load
#
if [ -d $HOME/.bash.before/ ]; then
  if [ "$(ls -A $HOME/.bash.before/)" ]; then
    for config_file in $(find $HOME/.bash.before -name '*.sh' | sort) ; do
      [ -n "${DEBUG}" ] && echo sourcing $config_file
      source $config_file ;
    done
  fi
fi
