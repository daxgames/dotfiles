#!/usr/bin/env bash

export version="${1:-main}"

cd ~/.yadr

git checkout ${version}


# ln -sf ${HOME}/.yadr/ctags/ctags ${HOME}/.ctags
# ln -sf ${HOME}/.yadr/vimify/editrc ${HOME}/.editrc
# ln -sf ${HOME}/.yadr/ruby/gemrc ${HOME}/.gemrc
# ln -sf ${HOME}/.yadr/git/gitconfig ${HOME}/.gitconfig
# ln -sf ${HOME}/.yadr/git/gitignore ${HOME}/.gitignore
# ln -sf ${HOME}/.yadr/vimify/inputrc ${HOME}/.inputrc
# ln -sf ${HOME}/.yadr/irb/pryrc ${HOME}/.pryrc
# ln -sf ${HOME}/.yadr/ruby/rdebugrc ${HOME}/.rdebugrc
# ln -sf ${HOME}/.yadr/tmux/tmux.conf ${HOME}/.tmux.conf
# ln -sf ${HOME}/.yadr/vim ${HOME}/.vim
# ln -sf ${HOME}/.yadr/vimrc ${HOME}/.vimrc
# ln -sf ${HOME}/.yadr/zsh/prezto/runcoms/zlogin ${HOME}/.zlogin
# ln -sf ${HOME}/.yadr/zsh/prezto/runcoms/zlogout ${HOME}/.zlogout
# ln -sf ${HOME}/.yadr/zsh/prezto ${HOME}/.zprezto
# ln -sf ${HOME}/.yadr/zsh/prezto/runcoms/zprofile ${HOME}/.zprofile
# ln -sf ${HOME}/.yadr/zsh/prezto/runcoms/zshenv ${HOME}/.zshenv
if [[ $version == main ]] ; then
  ln -sf ${HOME}/.yadr/vim ${HOME}/.vim
  ln -sf ${HOME}/.yadr/irb/pryrc ${HOME}/.pryrc
  ln -sf ${HOME}/.yadr/zsh/prezto-override/zpreztorc ${HOME}/.zpreztorc
  ln -sf ${HOME}/.yadr/zsh/prezto-override/zshrc ${HOME}/.zshrc
  ln -sf ${HOME}/.yadr/README.md ${HOME}/.README.md
  [[ -L ${HOME}/.README.md.backup ]] && rm -f ~/.README.md.backup
else
  ln -sf $HOME/.yadr/zsh/zshrc $HOME/.zshrc
  rm -f ${HOME}/.vim
  [[ -L ${HOME}/.pryrc ]] && rm ${HOME}/.pryrc
fi

echo ""
echo "   _     _           _         "
echo "  | |   | |         | |        "
echo "  | |___| |_____  __| | ____   "
echo "  |_____  (____ |/ _  |/ ___)  "
echo "   _____| / ___ ( (_| | |      "
echo "  (_______\_____|\____|_|      "
echo ""
echo "YADR has been switched to the '${version}' branch. Please restart your terminal and vim."

