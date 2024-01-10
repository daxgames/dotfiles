# Load any user customizations prior to load
#
if [ -d $HOME/.bash.before/ ]; then
  if [ "$(ls -A $HOME/.bash.before/)" ]; then
    for config_file in $(find $HOME/.bash.before -name '*.sh') ; do source $config_file ; done
  fi
fi
