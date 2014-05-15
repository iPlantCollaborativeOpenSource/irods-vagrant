# -*- mode: ruby -*-
# vi: set ft=ruby :

# Please upgrade Vagrant from:
#     https://www.vagrantup.com/downloads.html
# Please install an optional but recommended plugin:
#     vagrant plugin install vagrant-cachier

# Ubuntu note: The repository version of vagrant for Ubuntu
# 14.04 provides ruby 1.9 which does not enable the
# recommended plugin vagrant-cachier. The download
# version of vagrant provides ruby 2 which does.

# Vagrant 1.5 provides Ruby 2.x and changes config.vm.box
# and `vagrant box add` to support "ubuntu/trusty64"
# without need for a box_url.
Vagrant.require_version ">= 1.5"

# Vagrantfile API version 2 is the better developed and
# documented version since Vagrant 1.1.
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # See documentation for configuring a Vagrantfile:
  # http://docs.vagrantup.com/v2/getting-started/index.html
  config.vm.box = "ubuntu/trusty64"

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances
    # of the same base box: 
    config.cache.scope = :box
    # You may consider setting: config.cache.synced_folder_opts
    # For more information please check:
    # http://fgrehm.viewdocs.io/vagrant-cachier/usage
    # http://docs.vagrantup.com/v2/synced-folders/basic_usage.html
  end

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host-only networking does not.
  config.vm.network "forwarded_port", guest: 1247, host: 1247
  config.vm.network "forwarded_port", guest: 22, host: 50022

  config.vm.provision "shell", path: "irods.sh"
end
