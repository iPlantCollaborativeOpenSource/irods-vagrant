## iRODS Vagrant VM

This project allows users to set up a VM running a basic iRODS install using Vagrant and VirtualBox. This gives users a reproducable iRODS environment to do work against.

Vagrant - http://www.vagrantup.com/

VirtualBox - https://www.virtualbox.org/

This project has only been tested on OS X. The VM that is created will run Ubuntu 12.04 LTS.

# Installation

* Install VirtualBox following the instructions at the VirtualBox site listed above.

* Install Vagrant following the instructions at the Vagrant site listed above.

* Clone the code in this repo.

* Run 'vagrant up' in a terminal from inside the cloned repo.

# Notes

* Your local port 1247 will be forwarded to port 1247 in the VM.

* 'vagrant reload' does not reinstall iRODS. If your iRODS install gets hosed, do a 'vagrant destroy' followed by a 'vagrant up'. This will completely destroy the VM, so make sure any work that you need is backed up first.

* The iRODS username is 'rods'. The password is 'rods'. The zone is 'tempZone'

* Don't run this VM in production.

* Don't store any sensitive information in this VM.