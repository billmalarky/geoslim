# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  #=========================================================================================#
  #===================================== CONFIGURATION =====================================#
  #=========================================================================================#

  # HOSTNAME - Change to your local development URL
  config.vm.hostname = "geoslim.local"

  # INTERNAL NETWORK - The IP to use when automatically configuring your hosts file
  config.vm.network :private_network, ip: "192.168.100.100"
  #config.vm.network "forwarded_port", guest: 80, host: 8080

  # VM CONFIGURATION - DO NOT EDIT - Defines the attributes of the VM
  config.vm.box = "chef/fedora-19"
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    #vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"] #this may help speed up guest machine downloads.
  end

  # Run the auto-setup script
  config.vm.provision :shell, :path => "vagrant/bootstrap.sh"
end
