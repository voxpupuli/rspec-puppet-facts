# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "debian-7-x86_64" do |host|
    host.vm.box = "debian-73-x64-virtualbox-nocm"
    host.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/debian-73-x64-virtualbox-nocm.box"
    #host.vm.provision "shell", inline: "apt-get install -y bundler"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
  config.vm.define "redhat-6-x86_64" do |host|
    host.vm.box = "centos-65-x64-virtualbox-nocm"
    host.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-nocm.box"
    #host.vm.provision "shell", inline: "yum -y install bundler"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
end
