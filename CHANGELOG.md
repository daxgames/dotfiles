2024-01-15
==================
* Enhanced Linux Support
  * RedHat and Debian based distros are supported.
  * `install.sh` installs Ruby and rake are installed using native package managers ([yum|dnf]/apt-get)..
* Limited `bash` Shell Support.
  * Aliases, Git config, Git Prompt, IRB/Pry, Tmux Config, Vim are included.
  * `~/.yadr/bash/*.sh` are sourced from this repo.
  * `~/.bash.before/` and `~/.bash.after` folders are created and `*.sh` sourced for user customization..
  * Pre-existing `~/.bashrc` is moved to `~/.bash.after/001_bashrc.sh`
  * `~/.bashrc` is symlinked to `~/.yadr/bash/001_bashrc`
* Configurable using ENV variables for customized unattendend installation.
  * `__YADR_INSTALL_BASH=[y|n]` - Install `bash` configs (color, aliases).
  * `__YADR_INSTALL_CTAGS=[y|n]` - Install `ctags` config (better js/ruby support).
  * `__YADR_INSTALL_GIT=[y|n]` - Install `git` configs (color, aliases).
  * `__YADR_INSTALL_IRB=[y|n]` - Install `irb` configs (more colorful).
  * `__YADR_INSTALL_PREZTO=[y|n]` - Install `prezto` & zsh enhancements.
  * `__YADR_INSTALL_RUBY=[y|n]` - Install `ruby` config (faster/no docs).
  * `__YADR_INSTALL_TMUX=[y|n]` - Install `tmux` config.
  * `__YADR_INSTALL_VIMIFICATION=[y|n]` - Install `vimification` of command line tools.
  * `__YADR_INSTALL_ZSH=[y|n]` - Install `zsh` support in Linux.

2024-01-15
==================
  * Support for running zeus commands for rspec (`zl` and `zr`)
  * Ctrl-x and Ctrl-z to navigate the quickfix list

2014-06-01
==================
 * Change Cmd-Space to Ctrl-Space for vim autocomplete so it doesn't conflict with osx spotlight by default, and so there are no additional steps to install.

2014-02-15
==================

 * Replace Git Grep with Ag and remove unused plugins
 * Sneak: hit Space and type two letters to quickly jump somewhere
 * Added Ctrl-R, reverse history search for :commands
 * Remove ;; semicolon mapping. Messes with regular semicolon usage (find next char)
 * Change to Lightline instead of Airline [Fix #418]

Jan 5, 2013
==================

* Switch to lightline instead of airline for status bar. Works better in terminal vim and should be faster.
* Added investigate.vim (gK for docs)
* Fix homebrew installation of macvim with lua enabled, and fix deprecated homebrew install.

Dec 17, 2013
==================

* Cleanup of README to make it more palatable, focusing on the primary key bindings
* Improved integration with Ag, giving ,ag and ,af aliases
* Got rid of conque term, implemented a "send to iTerm" rspec runner (invoke with ,rs ,rl ,ss ,sl) for the rspec and spring/rspec versions.

March 29, 2013
==================

* Migrated to Vundle instead of pathogen for easier bundle management
* Added Silver Searcher for lightning fast :Gsearch
