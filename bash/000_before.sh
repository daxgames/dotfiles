# Load any user customizations prior to load
#
if [ -d $HOME/.bashrc.before/ ]; then
  if [ "$(ls -A $HOME/.bashrc.before/)" ]; then
    for config_file in $(find $HOME/.bashrc.before -name '*.sh') ; do
      [ -n "${DEBUG}" ] && echo sourcing $config_file
      source $config_file ;
    done
  fi
fi
