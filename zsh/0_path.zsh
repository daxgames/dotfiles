# path, the 0 in the filename causes this to load first

pathPrepend() {
  # Only adds to the path if it's not already there
  if ! echo $PATH | grep -E -q "(^|:)$1($|:)" ; then
    PATH=$1:$PATH
  fi
}

pathAppend() {
  # Only adds to the path if it's not already there
  if ! echo $PATH | grep -E -q "(^|:)$1($|:)" ; then
    PATH=$PATH:$1
  fi
}

# Remove duplicate entries from PATH:
pathDeDup() {
  PATH=$(echo "$PATH" | awk -v RS=':' -v ORS=":" '!a[$1]++{if (NR > 1) printf ORS; printf $a[$1]}')
}

if [[ "$(uname)" == "Linux" ]] ; then
  [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
elif [[ "$(uname)" == "Darwin" ]] ; then
  if [[ -f ~/homebrew/bin/brew ]] ; then
    eval "$(~/homebrew/bin/brew shellenv)"
  elif [[ -f ~/brew/bin/brew ]] ; then
    eval "$(~/brew/bin/brew shellenv)"
  elif [[ -f /usr/homebrew/bin/brew ]] ; then
    eval "$(/usr/homebrew/bin/brew shellenv)"
  elif [[ -f /opt/homebrew/bin/brew ]] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

[[ -d "$HOME/.virtualenvs/default/bin" ]] && pathPrepend "$HOME/.virtualenvs/default/bin"

pathDeDup

[[ -d ~/bin ]] && pathPrepend "$HOME/bin"
pathAppend "$HOME/.yadr/bin"
pathAppend "$HOME/.yadr/bin/yadr"
