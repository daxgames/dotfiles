# Load any custom after code
if [ -d $HOME/.bash.after/ ]; then
  if [ "$(ls -A $HOME/.bash.after/)" ]; then
    for config_file in $(find $HOME/.bash.after/ -name '*.sh' | sort) ; do
      [ -n "${DEBUG}" ] && echo sourcing $config_file
      source $config_file
    done
  fi
fi
