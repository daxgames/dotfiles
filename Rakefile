require 'rake'
require 'fileutils'

require File.join(File.dirname(__FILE__), 'bin', 'yadr', 'vundle')
require File.join(File.dirname(__FILE__), 'bin', 'yadr', 'vimplug')

$is_macos = RUBY_PLATFORM.downcase.include?('darwin')
$is_linux = RUBY_PLATFORM.downcase.include?('linux')
$linux = nil

desc 'Hook our dotfiles into system-standard positions.'
task :install => [:submodule_init, :submodules] do
  puts
  puts '======================================================'
  puts 'Welcome to YADR Installation.'
  puts '======================================================'
  puts

  if $is_linux
    $linux = linux_variant
  end

  if ! File.exist?("#{ENV['HOME']}/bin")
    run %{ mkdir -p $HOME/bin }
  end

  ENV['PATH'] = "#{File.join(ENV['HOME'], 'bin')}:#{ENV['PATH']}"
  install_homebrew if $is_macos

  if $is_linux
    run %{which brew}
    if $?.success?
      install_homebrew
    end

    if $linux["PLATFORM_FAMILY"] == "arch"
        run %{sudo pacman -S --noconfirm bat \
          fzf \
          git \
          github-cli \
          neovim \
          python3 \
          python-neovim \
          ripgrep \
          rubocop \
          rustup \
          shellcheck \
          vim
        }
        run %{[[ -n "$(command -v rustup)" ]] && rustup default stable}
    elsif $linux["PLATFORM_FAMILY"] == "debian"
        run %{sudo apt update -y}
        run %{sudo apt install -y bat \
          build-essential \
          cargo \
          fzf \
          gh \
          git\
          gradle \
          openjdk-17-jdk \
          python3-pip \
          rubocop \
          ruby-dev \
          shellcheck
        }
        run %{sudo ln -sf /bin/batcat /bin/bat}
    elsif $linux["PLATFORM_FAMILY"] == "rhel"
        run %{ sudo #{$linux['PACKAGE_MANAGER']} update -y}
        run %{ sudo #{$linux['PACKAGE_MANAGER']} groups install -y "Development Tools"}
        run %{ sudo #{$linux['PACKAGE_MANAGER']} install -y bat \
          fzf \
          gh \
          neovim \
          ripgrep \
          vim-enhanced \
          ruby-devel \
          rustup \
          shellcheck
        }
        run %{[[ -n "$(command -v rustup-init)" ]] && rustup-init -y}
    end

    install_zsh if want_to_install?('zsh (shell, enhancements))')

    install_from_github('bat', 'https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-i686-unknown-linux-musl.tar.gz')
    install_from_github('fzf', 'https://github.com/junegunn/fzf/releases/download/v0.54.1/fzf-0.54.1-linux_amd64.tar.gz', false)
    install_from_github('nvim', 'https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz')
    install_from_github('rg', 'https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep-14.1.0-x86_64-unknown-linux-musl.tar.gz')
    install_from_github('delta', 'https://github.com/dandavison/delta/releases/download/0.15.0/delta-0.15.0-x86_64-unknown-linux-musl.tar.gz')
  end

  install_python_modules

  install_rvm_binstubs
  # this has all the runcoms from this directory.
  install_files(Dir.glob('git/*')) if want_to_install?('git configs (color, aliases)')
  install_files(Dir.glob('irb/*')) if want_to_install?('irb pry configs (more colorful)')
  install_files(Dir.glob('ruby/*')) if want_to_install?('rubygems config (faster/no docs)')
  install_files(Dir.glob('ctags/*')) if want_to_install?('ctags config (better js/ruby support)')

  if want_to_install?('tmux config')
    install_files(Dir.glob('tmux/*'))
    if ! File::exist?("#{File.join(ENV['HOME'], '.tmux', 'plugins', 'tpm')}")
      run %{ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm }
    else
      run %{
        cd "#{File.join(ENV['HOME'], '.tmux', 'plugins', 'tpm')}"
        git pull --rebase
      }
    end
  end

  install_files(Dir.glob('tmux/*')) if want_to_install?('tmux config')
  install_files(Dir.glob('vimify/*')) if want_to_install?('vimification of command line tools')

  Rake::Task["install_prezto"].execute

  install_bash if want_to_install?('bash configs (color, aliases)')

  if want_to_install?('vim configuration (highly recommended)')
    run %{ ln -nfs "$HOME/.yadr/nvim" "$HOME/.config/nvim" }

    if $is_macos || ($is_linux && $linux['PLATFORM_FAMILY'] != 'debian')
      run %{which sdk}
      unless $?.success?
        run %{curl -s "https://get.sdkman.io" | bash}
      end

      run %{which gradle}
      unless $?.success?
        run %{source "${HOME}/.yadr/zsh/sdkman.zsh" ; sdk install gradle}
      end

      run %{which java}
      unless $?.success?
        run %{source "${HOME}/.yadr/zsh/sdkman.zsh" ; sdk install java 17.0.11-amzn}
      end
    end

    run %{which node}
    unless $?.success?
      run %{which nvm}
      unless $?.success?
        run %{curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash}
      end
    end

    if File.exist?(File.join('/opt/nvim-linux64/bin/nvim')) && $is_linux
      run %{ ln -nsf "/opt/nvim-linux64/bin/nvim" "$HOME/bin/nvim" }
    end

    install_files(Dir.glob('{vim,vimrc}'))
    Rake::Task["install_vundle"].execute

    # run %{pip3 install tmuxp}
    if $is_macos || $linux['PLATFORM_FAMILY'] != "arch"
      run %{pip3 install --user neovim} # For NeoVim plugins
      run %{pip3 install --user pynvim} # For NeoVim plugins
    end
    run %{gem install neovim --user-install} # For NeoVim plugins

    if File.exist?(File.join(ENV['HOME'], '.vimrc.before'))
      run %{ ln -sf "$HOME/.vimrc.before" "$HOME/.config/nvim/settings/before/000-userconfig-vimrc.before.vim" }
    end

    if File.exist?(File.join(ENV['HOME'], '.vimrc.after'))
      run %{ ln -sf "$HOME/.vimrc.after" "$HOME/.config/nvim/settings/after/zzz-userconfig-vimrc.after.vim" }
    end

    Rake::Task["install_vimplug"].execute
  end

  run %{ mkdir -p ~/.config/ranger }
  run %{ ln -nfs ~/.yadr/ranger ~/.config/ranger }

  run %{ touch ~/.hushlogin }

  install_fonts

  if $is_macos
    install_term_theme
    run %{ ~/.yadr/iTerm2/bootstrap-iterm2.sh }
  end

  run_bundle_config

  save_config

  success_msg("installed")
end

task :install_prezto do
  if want_to_install?('prezto & zsh enhancements')
    install_prezto
  end
end

desc 'Updates the installation'
task :update do
  ENV["__YADR_UPDATE"] = "y"
  Rake::Task["install"].execute
  #TODO: for now, we do the same as install. But it would be nice
  #not to clobber zsh files
end

task :submodule_init do
  unless ENV["SKIP_SUBMODULES"]
    run %{ git submodule update --init --recursive }
  end
end

desc "Init and update submodules."
task :submodules do
  unless ENV["SKIP_SUBMODULES"]
    puts "======================================================"
    puts "Downloading YADR submodules...please wait"
    puts "======================================================"

    run %{
      cd "#{File.join(ENV['HOME'], '.yadr')}"
      git submodule update --recursive
      git clean -df
    }
    puts
  end
end

desc "Runs Vundle installer in a clean vim environment"
task :install_vundle do
  puts "======================================================"
  puts "Installing and updating vundles."
  puts "The installer will now proceed to run PluginInstall to install vundles."
  puts "======================================================"

  puts ""

  vundle_path = File.join('vim','bundle', 'vundle')
  unless File.exist?(vundle_path)
    run %{
      cd $HOME/.yadr
      git clone https://github.com/gmarik/vundle.git #{vundle_path}
    }
  end

  Vundle::update_vundle
end

desc "Runs Plug installer in a clean vim environment"
task :install_vimplug do
  puts "======================================================"
  puts "Installing and updating Neovim plugins."
  puts "The installer will now proceed to run PluginInstall to install plugs."
  puts "======================================================"

  puts ""

  vimplug_path = File.join(ENV['HOME'], '.local', 'share', 'nvim', 'site', 'autoload', 'plug.vim')
  unless File.exist?(vimplug_path)
    run %{
      curl -fLo #{vimplug_path} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    }
  end

  if "#{ENV['__YADR_UPDATE']}" == "y"
    VimPlug::update_plugins
  else
    VimPlug::install_plugins
  end
end

task :default => 'install'

private
def run(cmd)
  puts "[Running] #{cmd}"
  if RUBY_PLATFORM.downcase.include?("cygwin")
    system(cmd) unless ENV['DEBUG']
  else
    `#{cmd}` unless ENV['DEBUG']
  end
end

def save_config
  if ENV['__YADR_SAVE_CONFIG'] == 'y'
    if File.exist?("#{ENV['HOME']}/.bash.before")
      run %{ env | grep '__YADR_' | sed 's/^__YADR_/export __YADR_/' | sort > "#{ENV['HOME']}/.bash.before/yadr_config.sh" }
    end

    if File.exist?("#{ENV['HOME']}/.zsh.before")
      run %{ env | grep '__YADR_' | sed 's/^__YADR_/export __YADR_/' | sort > "#{ENV['HOME']}/.zsh.before/yadr_config.zsh" }
    end
  end
end

def number_of_cores
  if $is_macos
    cores = run %{ sysctl -n hw.ncpu }
  else
    cores = run %{ nproc }
  end
  puts
  cores.to_i
end


def linux_variant
  linux = {
    :PLATFORM => nil,
    :PLATFORM_FAMILY => nil,
    :PLATFORM_VERSION => nil,
    :PACKAGE_MANGER => nil
  }

  if File.exist?("/etc/os-release")
    puts "Determining Linux OS using '/etc/os-release'..."
    File.open('/etc/os-release', 'r').read.each_line do |line|
      (key, value) = line.strip.gsub('"', '').split('=')
      if key.casecmp("id") == 0
        linux["PLATFORM"] = value
      elsif key.casecmp("id_like") == 0
        linux["PLATFORM_FAMILY"] = value
      elsif key.casecmp("version_id") == 0
        linux["PLATFORM_VERSION"] = value
      end
    end

    linux["PLATFORM_FAMILY"] = "rhel"   if linux["PLATFORM"] == "centos"
    linux["PLATFORM_FAMILY"] = "rhel"   if linux["PLATFORM"] == "fedora"
    linux["PLATFORM_FAMILY"] = "debian" if linux["PLATFORM"] == "debian"
  elsif File.exist?("/etc/redhat-release")
    linux["PLATFORM"] => "redhat"
    linux["PLATFORM_FAMILY"] => "rhel"
  end

  if linux["PLATFORM_FAMILY"] == "arch"
    linux["PACKAGE_MANAGER"] = "pacman"
  elsif linux["PLATFORM_FAMILY"] == "debian"
    linux["PACKAGE_MANAGER"] = "apt"
  elsif linux["PLATFORM_FAMILY"] == "rhel"
    linux["PACKAGE_MANAGER"] = "dnf"
    if linux["PLATFORM_VERSION"].to_i < 8
      linux["PACKAGE_MANAGER"] = "yum"
    end
  end

  # linux.each do |key, value|
  #   puts "#{key}: #{value}"
  # end

  return linux
end

def run_bundle_config
  return unless system("which bundle")

  bundler_jobs = number_of_cores - 1
  puts "======================================================"
  puts "Configuring Bundlers for parallel gem installation"
  puts "======================================================"
  run %{ bundle config --global jobs #{bundler_jobs} }
  puts
end

def install_rvm_binstubs
  puts "======================================================"
  puts "Installing RVM Bundler support. Never have to type"
  puts "bundle exec again! Please use bundle --binstubs and RVM"
  puts "will automatically use those bins after cd'ing into dir."
  puts "======================================================"
  run %{ chmod +x $rvm_path/hooks/after_cd_bundler }
  puts
end

def install_zsh
  run %{which zsh}
  unless $?.success?
    puts "======================================================"
    puts "Installing Zsh...If it's already"
    puts "installed, this will do nothing."
    puts "======================================================"

    if $linux["PLATFORM_FAMILY"] == "arch"
        puts "Installing 'zsh' on 'arch'..."
        run %{sudo pacman -S --noconfirm zsh}
    else
      puts "Installing 'zsh' on '#{$linux['PLATFORM_FAMILY']}'..."
      run %{ sudo #{$linux['PACKAGE_MANAGER']} install -y zsh }
    end
  end
end

def install_from_github(app_name, download_url, strip = true)
  run %{which #{app_name}}
  unless $?.success?
    download_path = File.join('/tmp',"#{app_name}.tar.gz")
    install_path = File.join(ENV['HOME'], '.local', app_name)
    link_path = File.join(ENV['HOME'], 'bin', app_name)
    puts "======================================================"
    puts "Installing/Updating '#{app_name}' to '#{install_path}'..."
    puts "======================================================"
    puts "Downloading #{download_url}"
    run %{ curl -Lo #{download_path} #{download_url} }
    run %{ rm -rf #{install_path} }
    run %{ mkdir -p #{install_path} }
    if strip
      run %{ tar -C #{install_path} --strip-components=1 -xzf #{download_path} }
    else
      run %{ tar -C #{install_path} -xzf #{download_path} }
    end
    run %{ rm -f #{download_path} }
    run %{ ln -sf $(find #{install_path} -type f -name '#{app_name}') #{link_path} }
  end
end

def install_python_modules
  run %{which pip}
  unless $?.success?
    puts "======================================================"
    puts "Installing Python Pip...If it's already"
    puts "installed, this will do nothing."
    puts "======================================================"
    if ENV['PLATFORM_FAMILY'] == 'debian'
      run %{ sudo apt install -y pip }
    elsif ENV['PLATFORM_FAMILY'] == 'rhel'
      if ENV['PLATFORM_VERSION'].to_i < 8
        run %{ sudo yum install -y python3-pip }
      else
        run %{ sudo dnf install -y python3-pip }
      end
    end
  end

  if ENV['PLATFORM_FAMILY'] == 'debian'
    run %{ pip install pynvim }
  elsif ENV['PLATFORM_FAMILY'] == 'rhel'
    run %{ pip3 install pynvim }
  end
end

def install_homebrew
  run %{which brew}
  unless $?.success?
    puts "======================================================"
    puts "Installing Homebrew, the OSX package manager...If it's"
    puts "already installed, this will do nothing."
    puts "======================================================"

    if $is_macos
      run %{bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"}
    else
      puts "Running Homebrew 'install.sh' on Linux..."
      if ! File.exist?('/home/linuxbrew')
        run %{sudo mkdir -p /home/linuxbrew}
        run %{sudo chmod 777 /home/linuxbrew}
      end

      run %{yes | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"}

      puts "Configuring 'brew shellenv' on Linux..."
      ENV['HOMEBREW_PREFIX'] = "/home/linuxbrew/.linuxbrew"
      ENV['HOMEBREW_CELLAR'] = "/home/linuxbrew/.linuxbrew/Cellar"
      ENV['HOMEBREW_REPOSITORY'] = "/home/linuxbrew/.linuxbrew/Homebrew"
      ENV['PATH'] = "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:" + ENV['PATH']
      ENV['MANPATH'] = "/home/linuxbrew/.linuxbrew/share/man:" + ENV['MANPATH'].to_s
      ENV['INFOPATH'] ="/home/linuxbrew/.linuxbrew/share/info:" + ENV['INFOPATH'].to_s

      run %{which brew}
      unless $?.success?
        puts "'brew' is NOT in the path!"
        exit 0
      end
    end
  end

  puts
  puts
  puts "======================================================"
  puts "Updating Homebrew."
  puts "======================================================"
  run %{brew update}
  puts
  puts
  puts "======================================================"
  puts "Installing Homebrew and other packages..."
  puts "======================================================"
  if ENV['CI'] then
    # A minimal Brewfile to speed up CI Builds
    run %{brew bundle install --verbose --file=test/Brewfile_ci}
  else
    run %{brew bundle install --verbose}
  end
  puts
  puts
end

def install_fonts
  puts "======================================================"
  puts "Installing patched fonts for Powerline/Lightline."
  puts "======================================================"
  run %{ cp -f $HOME/.yadr/fonts/* $HOME/Library/Fonts } if $is_macos
  run %{ mkdir -p ~/.fonts && cp ~/.yadr/fonts/* ~/.fonts && fc-cache -vf ~/.fonts } if $is_linux
  puts
end

def install_term_theme
  puts "======================================================"
  puts "Installing iTerm2 solarized theme."
  puts "======================================================"
  run %{ /usr/libexec/PlistBuddy -c "Add :'Custom Color Presets':'Solarized Light' dict" ~/Library/Preferences/com.googlecode.iterm2.plist }
  run %{ /usr/libexec/PlistBuddy -c "Merge 'iTerm2/Solarized Light.itermcolors' :'Custom Color Presets':'Solarized Light'" ~/Library/Preferences/com.googlecode.iterm2.plist }
  run %{ /usr/libexec/PlistBuddy -c "Add :'Custom Color Presets':'Solarized Dark' dict" ~/Library/Preferences/com.googlecode.iterm2.plist }
  run %{ /usr/libexec/PlistBuddy -c "Merge 'iTerm2/Solarized Dark.itermcolors' :'Custom Color Presets':'Solarized Dark'" ~/Library/Preferences/com.googlecode.iterm2.plist }

  # If iTerm2 is not installed or has never run, we can't autoinstall the profile since the plist is not there
  if !File.exist?(File.join(ENV['HOME'], '/Library/Preferences/com.googlecode.iterm2.plist'))
    puts "======================================================"
    puts "To make sure your profile is using the solarized theme"
    puts "Please check your settings under:"
    puts "Preferences> Profiles> [your profile]> Colors> Load Preset.."
    puts "======================================================"
    return
  end

  # Ask the user which theme he wants to install
  message = "Which theme would you like to apply to your iTerm2 profile?"
  color_scheme = ask message, iTerm_available_themes

  return if color_scheme == 'None'

  color_scheme_file = File.join('iTerm2', "#{color_scheme}.itermcolors")

  # Ask the user on which profile he wants to install the theme
  profiles = iTerm_profile_list
  message = "I've found #{profiles.size} #{profiles.size>1 ? 'profiles': 'profile'} on your iTerm2 configuration, which one would you like to apply the Solarized theme to?"
  profiles << 'All'
  selected = ask message, profiles

  if selected == 'All'
    (profiles.size-1).times { |idx| apply_theme_to_iterm_profile_idx idx, color_scheme_file }
  else
    apply_theme_to_iterm_profile_idx profiles.index(selected), color_scheme_file
  end
end

def iTerm_available_themes
   Dir['iTerm2/*.itermcolors'].map { |value| File.basename(value, '.itermcolors')} << 'None'
end

def iTerm_profile_list
  profiles=Array.new
  begin
    profiles <<  %x{ /usr/libexec/PlistBuddy -c "Print :'New Bookmarks':#{profiles.size}:Name" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null}
  end while $?.exitstatus==0
  profiles.pop
  profiles
end

def ask(message, values)
  puts message
  while true
    values.each_with_index { |val, idx| puts " #{idx+1}. #{val}" }
    selection = STDIN.gets.chomp
    if (Float(selection)==nil rescue true) || selection.to_i < 0 || selection.to_i > values.size+1
      puts "ERROR: Invalid selection.\n\n"
    else
      break
    end
  end
  selection = selection.to_i-1
  values[selection]
end

def install_bash
  puts
  puts "Installing Bash Enhancements..."

  puts
  puts "Creating directories for your customizations..."
  run %{ mkdir -p $HOME/.bash.before }
  run %{ mkdir -p $HOME/.bash.after }

  if ! File.exist?("#{ENV['HOME']}/.bash-git-prompt")
    puts
    puts "Configuring Git aware prompt..."
    run %{ git clone "https://github.com/maximus-codeshuttle/bash-git-prompt.git" "#{ENV['HOME']}/.bash-git-prompt" }
  end

  # Preserve pre-existing ~/.bashrc
  if File.exist?(File.join(ENV['HOME'], '.bashrc')) && ! File.exist?( File.join(ENV['HOME'], '.bash.after', '001_bashrc.sh'))
    puts
    puts "Preserving existing '~/.bashrc' filw..."
    FileUtils.mv(File.join(ENV['HOME'], '.bashrc'), File.join(ENV['HOME'], '.bash.after', '001_bashrc.sh'))
  end

  install_files(Dir.glob('bash/bashrc'), :symlink)
end

def install_prezto
  run %{which zsh}
  if $?.success?
    puts
    puts "Installing Prezto (ZSH Enhancements)..."

    if RUBY_PLATFORM.downcase.include?("cygwin")
      run %{ cmd /c "mklink /d "%USERPROFILE%\.zprezto" "%USERPROFILE%\.yadr\zsh\prezto"" }
    else
      run %{ ln -nfs "$HOME/.yadr/zsh/prezto" "${ZDOTDIR:-$HOME}/.zprezto" }
    end

    # The prezto runcoms are only going to be installed if zprezto has never been installed
    install_files(Dir.glob('zsh/prezto/runcoms/zlogin'), :symlink)
    install_files(Dir.glob('zsh/prezto/runcoms/zlogout'), :symlink)
    install_files(Dir.glob('zsh/prezto/runcoms/zprofile'), :symlink)
    install_files(Dir.glob('zsh/prezto/runcoms/zshenv'), :symlink)

  puts
  puts "Overriding prezto ~/.zpreztorc with YADR's zpreztorc to enable additional modules..."
  run %{ ln -nfs "$HOME/.yadr/zsh/prezto-override/zpreztorc" "${ZDOTDIR:-$HOME}/.zpreztorc" }
  # run %{ ln -s ~/.zprezto/modules/prompt/external/powerlevel9k/powerlevel9k.zsh-theme ~/.zprezto/modules/prompt/functions/prompt_powerlevel9k_setup }
  puts "Overriding prezto ~/.zshrc with YADR's zshrc to enable future customization..."
  install_files(Dir.glob('zsh/prezto-override/zshrc'), :symlink)
  puts "Overriding prezto ~/.zpreztorc with YADR's .zpreztorc to enable future customization..."
  install_files(Dir.glob('zsh/prezto-override/zpreztorc'), :symlink)

  puts
  puts "Creating directories for your customizations"
  run %{ mkdir -p $HOME/.zsh.before }
  run %{ mkdir -p $HOME/.zsh.after }
  run %{ mkdir -p $HOME/.zsh.prompts }

    if want_to_install?('zsh_default_shell (make zsh the default shell))')
      if "#{ENV['SHELL']}".include? 'zsh' then
        puts "Zsh is already configured as your shell of choice. Restart your session to load the new settings"
      else
        puts "Setting zsh as your default shell"
        if File.exist?("/usr/local/bin/zsh")
          if File.readlines("/private/etc/shells").grep("/usr/local/bin/zsh").empty?
            puts "Adding zsh to standard shell list"
            run %{ echo "/usr/local/bin/zsh" | sudo tee -a /private/etc/shells }
          end
          run %{ sudo chsh -s /usr/local/bin/zsh $USER }
        elsif File.exist?("/home/linuxbrew/.linuxbrew/bin/zsh")
          if File.readlines("/etc/shells").grep("/home/linuxbrew/.linuxbrew/bin/zsh").empty?
            puts "Adding zsh to standard shell list"
            run %{ echo "/home/linuxbrew/.linuxbrew/bin/zsh" | sudo tee -a /etc/shells }
          end
          run %{ sudo chsh -s /home/linuxbrew/.linuxbrew/bin/zsh $USER }
        else
          puts "Falling back to default/system zsh"
          run %{ chsh -s /bin/zsh }
        end
      end
    end
  end
end

def want_to_install? (section)
  # Allow configuration throught env varialbes
  install_type = section.split(' ')[0].upcase()
  install_env = ENV["__YADR_INSTALL_#{install_type}"] || ''

  if ! install_env.to_s.empty?
    ENV["__YADR_SAVE_CONFIG"] = 'y'
    install_env == 'y'
  elsif ENV["ASK"]=="true" && $stdout.isatty
    puts "Would you like to install configuration files for: #{section}? [y]es, [n]o"
    STDIN.gets.chomp == 'y'
    # set env var to match user answer so we do not ask again
    ENV["__YADR_SAVE_CONFIG"] = 'y'
    ENV["__YADR_INSTALL_#{install_type}"] = STDIN.gets.chomp
    ENV["__YADR_INSTALL_#{install_type}"] == 'y'
  else
    ENV["__YADR_INSTALL_#{install_type}"] == 'y'
    true
  end
end

def install_files(files, method = :symlink)
  files.each do |f|
    file = f.split('/').last
    source = "#{ENV["PWD"]}/#{f}"
    target = "#{ENV["HOME"]}/.#{file}"

    if RUBY_PLATFORM.downcase.include?("cygwin")
      source=`cygpath -d "#{source}"`
      target=`cygpath -d "#{target}"`
    end

    puts "======================#{file}=============================="
    puts "Source: #{source}"
    puts "Target: #{target}"

    if File.exist?(target) && (!File.symlink?(target) || (File.symlink?(target) && File.readlink(target) != source))
      puts "[Overwriting] #{target}...leaving original at #{target}.backup..."
      run %{ mv "$HOME/.#{file}" "$HOME/.#{file}.backup" }
    end

    if method == :symlink
      if RUBY_PLATFORM.downcase.include?("cygwin")
        if Dir.exist?(target)
          run %{ cmd /c "mklink /d "#{target}" "#{source}"" }
        else
          run %{ cmd /c "mklink "#{target}" "#{source}"" }
        end
      else
        run %{ ln -nfs "#{source}" "#{target}" }
      end
    else
      run %{ cp -f "#{source}" "#{target}" }
    end

    puts "=========================================================="
    puts
  end
end

def needs_migration_to_vundle?
  File.exist? File.join('vim', 'bundle', 'tpope-vim-pathogen')
end


def list_vim_submodules
  result=`git submodule -q foreach 'echo $name"||"\`git remote -v | awk "END{print \\\\\$2}"\`'`.select{ |line| line =~ /^vim.bundle/ }.map{ |line| line.split('||') }
  Hash[*result.flatten]
end

def apply_theme_to_iterm_profile_idx(index, color_scheme_path)
  values = Array.new
  16.times { |i| values << "Ansi #{i} Color" }
  values << ['Background Color', 'Bold Color', 'Cursor Color', 'Cursor Text Color', 'Foreground Color', 'Selected Text Color', 'Selection Color']
  values.flatten.each { |entry| run %{ /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':#{index}:'#{entry}'" ~/Library/Preferences/com.googlecode.iterm2.plist } }

  run %{ /usr/libexec/PlistBuddy -c "Merge '#{color_scheme_path}' :'New Bookmarks':#{index}" ~/Library/Preferences/com.googlecode.iterm2.plist }
  run %{ defaults read com.googlecode.iterm2 }
end

def success_msg(action)
  puts %q{
   _     _           _
  | |   | |         | |
  | |___| |_____  __| | ____
  |_____  (____ |/ _  |/ ___)
   _____| / ___ ( (_| | |
  (_______\_____|\____|_|
  }
  puts "YADR has been #{action}. Please restart your terminal and vim."
end
