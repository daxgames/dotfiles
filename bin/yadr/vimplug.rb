require 'fileutils'

module VimPlug
  @plugins_path = File.expand_path File.join(ENV['HOME'], '.config', 'nvim', 'plugins', 'userplugins.vim')

  def self.add_plugin_to_vimplug(plugin_repo)
    return if contains_plugin? plugin_repo

    plugins = plugin_from_file
    last_plugin_dir = plugins.rindex{ |line| line =~ /^Plug / }
    last_plugin_dir = last_plugin_dir ? last_plugin_dir+1 : 0
    plugins.insert last_plugin_dir, "Plug \"#{plugin_repo}\""
    write_plugin_to_file plugins
  end

  def self.remove_plugin_from_vimplug(plugin_repo)
    plugins = plugin_from_file
    deleted_value = plugins.reject!{ |line| line =~ /Plug "#{plugin_repo}"/ }

    write_plugin_to_file plugins

    !deleted_value.nil?
  end

  def self.plugin_list
    plugin_from_file.select{ |line| line =~ /^Plug .*/ }.map{ |line| line.gsub(/Plug "(.*)"/, '\1')}
  end

  def self.update_plugins
    system "nvim --noplugin -u #{ENV['HOME']}/.config/nvim/plugins/plugins.vim -N \"+set hidden\" \"+syntax on\" +PlugClean +PlugInstall! +qall"
  end


  private
  def self.contains_plugin?(plugin_name)
    FileUtils.touch(@plugins_path) unless File.exists? @plugins_path
    File.read(@plugins_path).include?(plugin_name)
  end

  def self.plugin_from_file
    FileUtils.touch(@plugins_path) unless File.exists? @plugins_path
    File.read(@plugins_path).split("\n")
  end

  def self.write_plugin_to_file(plugins)
    FileUtils.cp(@plugins_path, "#{@plugins_path}.bak")
    plugin_file = File.open(@plugins_path, "w")
    plugin_file.write(plugins.join("\n"))
    plugin_file.close
  end
end
