Vagrant.configure("2") do |config|
  config.vm.define "win10_vs2015" do |win10_vs2015|
    win10_vs2015.vm.hostname = 'win10-vs2015'
    win10_vs2015.vm.box = "senglin/win-10-enterprise-vs2015community"

    # win10-vs2015.vm.network :private_network, ip: "192.168.56.101"

    win10_vs2015.vm.provider :virtualbox do |v|
      # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      # v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--name", "win10-vs2015"]
    end
  end

  config.vm.define "win10_vs2022" do |win10_vs2022|
    win10_vs2022.vm.hostname = 'win10-vs2022'
    win10_vs2022.vm.box = "gusztavvargadr/visual-studio"

    # win10-vs2022.vm.network :private_network, ip: "192.168.56.102"

    win10_vs2022.vm.provider :virtualbox do |v|
      # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 8192]
      v.customize ["modifyvm", :id, "--name", "win10-vs2022"]
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end

    config.winrm.timeout = 21600

    config.vm.provision "shell" do |s|
      s.path = "scripts/cmder.ps1"
    end

    config.vm.provision "shell" do |s|
      s.path = "scripts/cmderdev.cmd"
    end

    config.vm.provision "shell" do |s|
      s.path = "scripts/vsc2022_uninstall.ps1"
    end

    config.vm.provision "shell" do |s|
      s.path = "scripts/vsc2022_install.ps1"
    end
  end
end
