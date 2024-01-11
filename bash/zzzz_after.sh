# Load any custom after code
if [ -d $HOME/.bashrc.after/ ]; then
  if [ "$(ls -A $HOME/.bashrc.after/)" ]; then
    for config_file in $(find $HOME/.bashrc.after -name '*.sh') ; do
      [ -n "${DEBUG}" ] && echo sourcing $config_file
      source $config_file
    done
  fi
fi
