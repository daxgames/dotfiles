require 'rake'
require 'fileutils'

$is_macos = RUBY_PLATFORM.downcase.include?("darwin")

desc "Hook our dotfiles into system-standard positions."
task :install => [:submodule_init, :submodules] do
  puts
  puts "======================================================"
  puts "Welcome to YADR Installation."
  puts "======================================================"
  puts

  install_homebrew

  install_rvm_binstubs
  # this has all the runcoms from this directory.
  install_files(Dir.glob('git/*')) if want_to_install?('git configs (color, aliases)')
  install_files(Dir.glob('irb/*')) if want_to_install?('irb/pry configs (more colorful)')
  install_files(Dir.glob('ruby/*')) if want_to_install?('rubygems config (faster/no docs)')
  install_files(Dir.glob('ctags/*')) if want_to_install?('ctags config (better js/ruby support)')
  install_files(Dir.glob('tmux/*')) if want_to_install?('tmux config')
  install_files(Dir.glob('vimify/*')) if want_to_install?('vimification of command line tools')
  install_files(Dir.glob('{vim,vimrc}'))

  if File.exists?(File.join(ENV['HOME'], '.vimrc.before'))
    run %{ ln -sf "$HOME/.vimrc.before" "$HOME/.config/nvim/settings/before/000-vimrc.before.vim" }
  end

  if File.exists?(File.join(ENV['HOME'], '.vimrc.after'))
    run %{ ln -sf "$HOME/.vimrc.after" "$HOME/.config/nvim/settings/after/zzz-vimrc.after.vim" }
  end

  if File.exists?(File.join(ENV['HOME'], '.vimrc.after'))
    run %{ ln -sf "$HOME/.vimrc.after" "$HOME/.config/nvim/settings/after/zzz-vimrc.after.vim" }
  end

  run %{ ln -nfs ~/.yadr/nvim ~/.config/nvim }

  run %{ mkdir -p ~/.config/ranger }
  run %{ ln -nfs ~/.yadr/ranger ~/.config/ranger }

  run %{ touch ~/.hushlogin }

  Rake::Task["install_prezto"].execute

  install_fonts

  if $is_macos
    run %{ ~/.yadr/iTerm2/bootstrap-iterm2.sh }
  end

  run_bundle_config

  success_msg("installed")
end

task :install_prezto do
  if want_to_install?('zsh enhancements & prezto')
    install_prezto
  end
end

desc 'Updates the installation'
task :update do
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
      cd $HOME/.yadr
      git submodule update --recursive
      git clean -df
    }
    puts
  end
end

task :default => 'install'

private
def run(cmd)
  puts "[Running] #{cmd}"
  `#{cmd}` unless ENV['DEBUG']
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
  r = { :distro => nil, :family => nil }

  if File.exists?('/etc/lsb-release')
    File.open('/etc/lsb-release', 'r').read.each_line do |line|
      r = { :distro => $1 } if line =~ /^DISTRIB_ID=(.*)/
    end
  end

  if File.exists?('/etc/debian_version')
    r[:distro] = 'Debian' if r[:distro].nil?
    r[:family] = 'Debian' if r[:variant].nil?
  elsif File.exists?('/etc/redhat-release') or File.exists?('/etc/centos-release')
    r[:family] = 'RedHat' if r[:family].nil?
    r[:distro] = 'CentOS' if File.exists?('/etc/centos-release')
  elsif File.exists?('/etc/SuSE-release')
    r[:distro] = 'SLES' if r[:distro].nil?
  end

  return r
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
      if ! File.exists?('/home/linuxbrew')
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

      if linux_variant[:distro] == 'Ubuntu' || linux_variant[:distro] == 'Debian'
        # Running on Debian/Ubuntu
        run %{sudo apt-get install build-essential}
      elsif linux_variant[:family] == 'Redhat'
        if linux_variant[:distro] == nil
          # Running on Redhat Linux
        elsif linux_variant[:distro] == 'Centos'
          # Running on Centos Linux
        end
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
  # run %{pip3 install tmuxp}
  run %{pip3 install --user neovim} # For NeoVim plugins
  run %{pip3 install --user pynvim} # For NeoVim plugins
  run %{gem install neovim} # For NeoVim plugins
  puts
  puts
end

def install_fonts
  puts "======================================================"
  puts "Installing patched fonts for Powerline/Lightline."
  puts "======================================================"
  run %{ cp -f $HOME/.yadr/fonts/* $HOME/Library/Fonts } if $is_macos
  run %{ mkdir -p ~/.fonts && cp ~/.yadr/fonts/* ~/.fonts && fc-cache -vf ~/.fonts } if !$is_macos
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

def install_prezto
  puts
  puts "Installing Prezto (ZSH Enhancements)..."

  run %{ ln -nfs "$HOME/.yadr/zsh/prezto" "${ZDOTDIR:-$HOME}/.zprezto" }

  # The prezto runcoms are only going to be installed if zprezto has never been installed
  install_files(Dir.glob('zsh/prezto-override/zshrc'), :symlink)
  install_files(Dir.glob('zsh/prezto/runcoms/zlogin'), :symlink)
  install_files(Dir.glob('zsh/prezto/runcoms/zlogout'), :symlink)
  install_files(Dir.glob('zsh/prezto-override/zpreztorc'), :symlink)
  install_files(Dir.glob('zsh/prezto/runcoms/zprofile'), :symlink)
  install_files(Dir.glob('zsh/prezto/runcoms/zshenv'), :symlink)

  # puts
  # puts "Overriding prezto ~/.zpreztorc with YADR's zpreztorc to enable additional modules..."
  # run %{ ln -nfs "$HOME/.yadr/zsh/prezto-override/zpreztorc" "${ZDOTDIR:-$HOME}/.zpreztorc" }
  # run %{ ln -s ~/.zprezto/modules/prompt/external/powerlevel9k/powerlevel9k.zsh-theme ~/.zprezto/modules/prompt/functions/prompt_powerlevel9k_setup }

  puts
  puts "Creating directories for your customizations"
  run %{ mkdir -p $HOME/.zsh.before }
  run %{ mkdir -p $HOME/.zsh.after }
  run %{ mkdir -p $HOME/.zsh.prompts }

  if "#{ENV['SHELL']}".include? 'zsh' then
    puts "Zsh is already configured as your shell of choice. Restart your session to load the new settings"
  else
    puts "Setting zsh as your default shell"
    if File.exists?("/usr/local/bin/zsh")
      if File.readlines("/private/etc/shells").grep("/usr/local/bin/zsh").empty?
        puts "Adding zsh to standard shell list"
        run %{ echo "/usr/local/bin/zsh" | sudo tee -a /private/etc/shells }
      end
      run %{ sudo chsh -s /usr/local/bin/zsh $USER }
    elsif File.exists?("/home/linuxbrew/.linuxbrew/bin/zsh")
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

def want_to_install? (section)
  if ENV["ASK"]=="true"
    puts "Would you like to install configuration files for: #{section}? [y]es, [n]o"
    STDIN.gets.chomp == 'y'
  else
    true
  end
end

def install_files(files, method = :symlink)
  files.each do |f|
    file = f.split('/').last
    source = "#{ENV["PWD"]}/#{f}"
    target = "#{ENV["HOME"]}/.#{file}"

    puts "======================#{file}=============================="
    puts "Source: #{source}"
    puts "Target: #{target}"

    if File.exists?(target) && (!File.symlink?(target) || (File.symlink?(target) && File.readlink(target) != source))
      puts "[Overwriting] #{target}...leaving original at #{target}.backup..."
      run %{ mv "$HOME/.#{file}" "$HOME/.#{file}.backup" }
    end

    if method == :symlink
      run %{ ln -nfs "#{source}" "#{target}" }
    else
      run %{ cp -f "#{source}" "#{target}" }
    end

    puts "=========================================================="
    puts
  end
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
