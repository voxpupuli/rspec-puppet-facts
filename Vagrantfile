# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "debian-6-x86_64" do |host|
    host.vm.box = "debian-607-x64-virtualbox-nocm"
    host.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/debian-607-x64-vbox4210-nocm.box"
    host.vm.provision "shell", inline: "apt-get update && apt-get install -y rubygems"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
  config.vm.define "debian-7-x86_64" do |host|
    host.vm.box = "debian-73-x64-virtualbox-nocm"
    host.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/debian-73-x64-virtualbox-nocm.box"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
  config.vm.define "ubuntu-12.04-x86_64" do |host|
    host.vm.box = "ubuntu-server-12042-x64-vbox4210-nocm"
    host.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210-nocm.box"
    host.vm.provision "shell", inline: "apt-get update && apt-get install -y rubygems"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
  config.vm.define "ubuntu-14.04-x86_64" do |host|
    host.vm.box = "puppetlabs/ubuntu-14.04-64-nocm"
    host.vm.box_url = "https://vagrantcloud.com/puppetlabs/ubuntu-14.04-64-nocm"
    host.vm.provision "shell", inline: "apt-get update && apt-get install -y ruby"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
  config.vm.define "centos-5-x86_64" do |host|
    host.vm.box = "centos-510-x64-virtualbox-nocm"
    host.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-510-x64-virtualbox-nocm.box"
    host.vm.provision "shell", inline: "curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \\curl -sSL https://get.rvm.io | bash -s stable"
    host.vm.provision "shell", inline: "source /etc/profile.d/rvm.sh && rvm install 1.8.7 && rvm use --create 1.8.7"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
  config.vm.define "centos-6-x86_64" do |host|
    host.vm.box = "centos-65-x64-virtualbox-nocm"
    host.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-nocm.box"
    host.vm.provision "shell", inline: "yum -y install rubygems"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
  config.vm.define "centos-7-x86_64" do |host|
    host.vm.box = "puppetlabs/centos-7.0-64-nocm"
    host.vm.box_url = "https://vagrantcloud.com/puppetlabs/centos-7.0-64-nocm"
    host.vm.provision "shell", inline: "yum -y install ruby"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
  config.vm.define "fedora-19-x86_64" do |host|
    host.vm.box = "chef/fedora-19"
    host.vm.provision "shell", inline: "yum -y install ruby"
    host.vm.provision "file", source: "Gemfile", destination: "Gemfile"
    host.vm.provision "shell", path: "get_facts.sh"
  end
end
