$script_cmder = <<-SCRIPT
choco install -y --force 7zip 7zip.install
choco install -y --force cmder
SCRIPT

$script_cmderdev = <<-SCRIPT
$env:path = "$env:path;c:\\tools\\cmder\\vendor\\git-for-windows\\cmd"
c:
cd \\Users\\Vagrant
git clone https://github.com/cmderdev/cmder cmderdev
TAKEOWN /F c:\\Users\\vagrant\\cmderdev /R /D y /s localhost /u vagrant /p vagrant
cd cmderdev
git remote add upstream  https://github.com/cmderdev/cmder
git pull upstream master

# cmd.exe "/K" '"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Auxiliary\\Build\\vcvars64.bat" && powershell -command "& ''c:\\Users\\Vagrant\\cmderdev\\scripts\\build.ps1'' -verbose -compile" && exit'
# copy c:\\Users\\Vagrant\\cmderdev\\launcher\\x64\\release\\cmder.exe c:\\Users\\Vagrant\\cmderdev
# cmd.exe "/K" '"C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\Community\\VC\\Auxiliary\\Build\\vcvars64.bat" && powershell -noexit -command "& ''build.ps1 -verbose -compile''"'

./build -verbose
copy C:\\Tools\\Cmder\\Cmder.exe .\\
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "cmderdev-10" do |win10|
    win10.vm.hostname = "cmderdev-10"
    win10.vm.box = "cmderdev-10"

    # win10.vm.network :private_network, ip: "192.168.56.101"

    win10.vm.provider :virtualbox do |v|
      # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--name", "cmderdev-10"]
      v.customize ["modifyvm", :id, "--ostype", "Windows10_64"]
      v.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
      v.customize ["modifyvm", :id, "--memory", 8192]
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      #v.customize ["setextradata", :id, "GUI/ScaleFactor", "1.75"]
    end
  end

  config.vm.define "cmderdev-11" do |win11|
    win11.vm.hostname = "cmderdev-11"
    win11.vm.box = "cmderdev-11"

    # win11.vm.network :private_network, ip: "192.168.56.111"

    win11.vm.provider :virtualbox do |v|
      # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--name", "cmderdev-11"]
      v.customize ["modifyvm", :id, "--ostype", "Windows11_64"]
      v.customize ["modifyvm", :id, "--graphicscontroller", "vboxvga"]
      v.customize ["modifyvm", :id, "--memory", 8192]
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      #v.customize ["setextradata", :id, "GUI/ScaleFactor", "1.75"]
    end
  end

  config.vm.define "cmderdev-10-pro-scaled" do |cmderdev|
    cmderdev.vm.hostname = 'cmderdev-10-pro'
    cmderdev.vm.box = "cmderdev_win10_pro"

    cmderdev.vm.provider :virtualbox do |v|
      # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--name", "cmderdev-pro"]
      v.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
      v.customize ["modifyvm", :id, "--memory", 8192]
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ["setextradata", :id, "GUI/ScaleFactor", "1.75"]
    end
  end
  config.vm.provision "shell", inline: $script_cmder
  config.vm.provision "shell", inline: $script_cmderdev
end
