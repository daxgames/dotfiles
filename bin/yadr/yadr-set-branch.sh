#!/usr/bin/env bash

export version="${1:-main}"

cd ~/.yadr

git checkout ${version}

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

