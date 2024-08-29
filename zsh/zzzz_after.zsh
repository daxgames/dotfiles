# Load any custom after code
if [ -d $HOME/.zsh.after/ ] ; then
  [[ ! -f $HOME/.zsh.after/env.zsh ]] && echo "# This is a starter file for you to add your settings to." >$HOME/.zsh.after/env.zsh
  for config_file in ($HOME/.zsh.after/*.zsh) ; do
    [[ -n "${__YADR_DEBUG}" ]] && echo "source $config_file"
    source $config_file
  done
fi

pathPrepend ${HOME}/bin
