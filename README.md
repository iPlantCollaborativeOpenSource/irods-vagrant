## iRODS 3.3 Vagrant VM

This project allows users to set up a VM running a basic `community` iRODS 3.3 install using <a href="http://www.vagrantup.com/
">Vagrant</a> and <a href="https://www.virtualbox.org">VirtualBox</a>.

This gives users a reproducable iRODS environment to do work against.


# Installation

* Install VirtualBox following the instructions at the VirtualBox site listed above.

* Install Vagrant following the instructions at the Vagrant site listed above.

* Clone the code in this repo.

* Run 'vagrant up' in a terminal from inside the cloned repo. 


# Starting up iRODS

* In a terminal in the cloned directory, run 'vagrant ssh'. This will ssh into the running VM.

* Run 'irodsctl start' to start up iRODS and use the `i-commands`.


# Notes

* Your local port 1247 will be forwarded to port 1247 in the VM.

* The iRODS username is 'rods'. The password is 'rods'. The zone is 'tempZone'.

* iRODS is not running when the VM is created.

* Don't run this VM in production.

* Don't store any sensitive information in this VM.
