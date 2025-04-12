# Makes git auto completion faster favouring for local completions
__git_files () {
    _wanted files expl 'local files' _files
}

function git_diff_changelog() {
  [[ -n "$1" ]] && base=$1 && shift
  echo "$(git diff $(git_diff_tags ${base}) -- CHANGELOG.md | grep "^+" | tail -n +2 | sed 's/\+//g')"
}

function git_diff_tags() {
  [[ $# == 2 ]] && echo "$1 $2"
  [[ $# == 1 ]] && echo "$1 $(git tag | grep "^v" |sort -V | tail -1)"
  [[ $# == 0 ]] && echo "$(git tag |sort -V| tail -2 |tr '\n' ' ')"
}

function git_tag_latest() {
  echo "$(git tag | grep "^v" |sort -V | tail -1)"
}

function git_tag_previous() {
  echo "$(git tag | grep "^v" |sort -V | tail -2 | head -n 1)"
}

function gh_release_previous() {
  gh release list | grep Latest | awk '{print $1}'
}

function gh_release_f() {
  local base=$(gh_release_previous)
  local target=dev
  if [[ $# == 1 ]] ; then
    local target=$1
  fi

  echo Previous Release: ${base}
  echo New Release:      $(git_tag_latest)
  echo Target Branch:    ${target}

  git_diff_changelog $base $(git_tag_latest)

  gh release create $(git_tag_latest) --notes "$(git_diff_changelog $base $(git_tag_latest))" --target ${target} --title $(git_tag_latest)
}

alias gcfg='git config'
alias gcfgg='git config --global'
alias gcfgu='git config -f ~/.gitconfig.user'
alias gh-release='gh_release_f $*'
