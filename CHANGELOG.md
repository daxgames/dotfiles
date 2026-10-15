## 2026-05-03 — Present

### Installation & Platform Support
- **Arch Linux**: Added `base-devel` (separate install), `python-pip`, and `pacman`-based pre-requisite handling (`bin/install_pacman.sh`)
- **Windows**: Added `bin/install-windows-pre.ps1` pre-install PowerShell script; removed `install.cmd`
- **Debian/Ubuntu**: Multiple `install.sh` cleanup passes for Ubuntu/Debian compatibility
- **Homebrew**: Added `Brewfile` with full tool list; support for `~/Applications` on macOS; Python venv creation when Homebrew is used; fallback to native Linux package manager when Homebrew is absent
- **`install.sh`**: Major overhaul — added update path, Brew/non-Brew detection via `uname`, CI/smoke test infra (`test/` directory), self-update support
- **Travis CI**: Added `.travis.yml` and `test/travis-*.sh` scripts for CI smoke testing

### Neovim (`nvim/`)
- Full Neovim config added as a first-class citizen alongside Vim:
  - `nvim/init.vim`, `nvim/lua/settings/` Lua config modules
  - Plugin configs: `neotree`, `nvterm`, `telescope`, `treesitter`, `nvim-completions`, `lsp-config`
  - Switched from `coc.nvim` to native LSP (`nvim-lsp-config`); `coc-settings.json` retained but `plugin-coc.vim` marked `.unused`
  - Added `gitgutter` plugin
  - Added `NvChad/nvterm` terminal plugin
  - Added `nvim/settings/` mirror of all vim settings for Neovim: keymaps, appearance, windows, wrapping, search, quickfix, tags, etc.
  - Treesitter: pinned to `master` branch; parser fixes (2024-01-12, 2025-12-16)
  - `nvim/dict/javascript.dict` — JavaScript word dictionary for completions
  - `.luarc.json` added for Lua LSP

### Vim (`vim/`)
- Added `NERDtree.vim` settings (tree on right side)
- Added `surround.vim`, `splitjoin.vim`, `vim-gotofile.vim`, `vim-sudo-write.vim` settings
- Removed `syntastic.vim`; Syntastic fully removed
- `yadr-appearance.vim`: OneHalfDark colorscheme support
- `yadr-keymap.vim` / `yadr-keymap-linux.vim`: Various keymap cleanups and additions
- `vundles/appearance.vundle`, `extras.vundle`: Added new plugins including `onehalf` colorscheme, NERDtree, gitgutter, etc.
- `vimrc`: Minor updates; disabled `vim→mvim` alias
- Removed `gruvbox` colorscheme; added `onehalf` dark/light

### iTerm2
- Added full iTerm2 profile: `com.googlecode.iterm2.plist`, `OneHalfDark/Light.itermcolors`, `bootstrap-iterm2.sh`, `xterm-256color.terminfo`
- iTerm2 settings moved to `~/.yadr.user/iTerm2`
- Fixed window/tab styles; window type set to 15

### ZSH / Prezto
- **New prompt themes**: `prompt_cmder_setup` (two-line Cmder-style), `prompt_lfilho_setup`, `prompt_kylewestcustom_setup`
- **Default prompt**: Changed to `daxgames` custom prompt with **git worktree awareness**
- `zpreztorc`: Significant updates to module list and options
- New ZSH modules: `fzf.zsh`, `git.zsh`, `kubectl.zsh`, `mcfly.zsh`, `nvm.zsh`, `cargo.zsh`, `sdkman.zsh`, `vagrant.zsh`, `secrets.zsh`, `key-bindings.zsh`
- `aliases.zsh`: Added `kubectl` and git aliases; `fzf` aliases with preview
- `0_path.zsh`: `pathDeDup` function; `~/bin` prepended at end of path setup
- `zsh-aliases.zsh`: Cleanup; `cat → bat` alias
- `zzzz_after.zsh` / `0000_before.zsh`: Sourcing order fixes

### Bash
- `bash/002_path.sh`: New path setup module
- `bash/cargo.sh`, `bash/sdkman.sh`: New shell integrations
- `bash/vi-mode`: Added vi-mode config (replacing `vi-mode.sh`)
- `bash/000_before.sh` / `bash/zzzz_after.sh`: Sourcing/ordering fixes

### Git
- `gitconfig`: Added `delta` as pager with OneHalfDark theme; credential helper made OS-aware; new aliases
- Added `git/README.md`, `git/gitattributes`
- `zsh/git.zsh` / `zsh/kubectl.zsh`: Extensive new git and kubectl aliases

### Tmux
- `tmux.conf`: Major rewrite — added TPM (Tmux Plugin Manager), new keybindings, status bar improvements
- Added `tmux/README.md`

### Ranger
- Full Ranger file manager config added: `rc.conf`, `rifle.conf`, `scope.sh`, `commands.py`, `commands_full.py`
- Ranger devicons plugin added (`ranger/plugins/devicons*.py`)

### Fonts
- Added **FiraCode Nerd Font** variants (Bold, Light, Medium, Regular, Retina `.otf`)
- Added `base16-lfilho.dark.sh` base16 color scheme

### Miscellaneous
- `bin/vimplug.rb`: Auto vim-plug installer
- `bin/yadr-extras-install` / `yadr-extras-install_linux`: Extras install scripts
- `bin/yadr-set-branch.sh` → `bin/yadr/yadr-set-branch.sh` (moved)
- `bin/fix-cedilla-in-linux.sh`: New utility
- `bin/macos`: macOS system defaults script expanded
- Removed Chrome extension (`chrome/`)
- `doc/screenshot-iterm-onehalfdark.png`: New screenshot
- `README.md`: Complete rewrite with updated screenshots and feature list


2024-01-15
==================
* `yadr-uninstall` script
* `yadr-set-branch` script
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
