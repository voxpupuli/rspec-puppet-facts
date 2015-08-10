#!/bin/bash

set -e

# Make Solaris use GNU tools by default
export PATH=/usr/gnu/bin:$PATH

# Fix for squeeze, el7, arch, opensuse12, opensuse13 and solaris
export PATH=$PATH:/var/lib/gems/1.8/bin/:/usr/local/bin:/root/.gem/ruby/2.1.0/bin:/usr/lib64/ruby/gems/1.9.1/gems/bundler-1.7.12/bin:/usr/lib64/ruby/gems/2.0.0/gems/bundler-1.7.12/bin:/usr/ruby/1.9/bin

# Install latest version of facter
gem install bundler --no-ri --no-rdoc --no-format-executable
bundle install --path vendor/bundler
operatingsystem=$(bundle exec facter operatingsystem | tr '[:upper:]' '[:lower:]')
operatingsystemrelease=$(bundle exec facter operatingsystemrelease)
operatingsystemmajrelease=$(bundle exec facter operatingsystemmajrelease)
lsbdistcodename=$(bundle exec facter lsbdistcodename)
hardwaremodel=$(bundle exec facter hardwaremodel)

# Fix for FreeBSD
[ "${hardwaremodel}" = 'amd64' ] && hardwaremodel='x86_64'

# Fix for Solaris
[ "${hardwaremodel}" = 'i86pc' ] && hardwaremodel='x86_64'

for version in 1.6.0 1.7.0 2.0.0 2.1.0 2.2.0 2.3.0 2.4.0; do
  FACTER_GEM_VERSION="~> ${version}" bundle update
  minor_version=$(echo $version | cut -c1-3)
  output_dir="/vagrant/${minor_version}"
  mkdir -p $output_dir
  case "${operatingsystem}" in
    archlinux|gentoo)
      output_file="${output_dir}/${operatingsystem}-${hardwaremodel}.facts"
      ;;
    openbsd)
      output_file="${output_dir}/${operatingsystem}-${operatingsystemrelease}-${hardwaremodel}.facts"
      ;;
    *)
      output_file="${output_dir}/${operatingsystem}-${operatingsystemmajrelease}-${hardwaremodel}.facts"
      ;;
  esac
  echo $version | grep -q -E '^1\.' &&
    FACTER_GEM_VERSION="~> ${version}" bundle exec facter -j | bundle exec ruby -e 'require "json"; jj JSON.parse gets' | tee $output_file ||
    FACTER_GEM_VERSION="~> ${version}" bundle exec facter -j | tee $output_file
done

minor_version=3.0
output_dir="/vagrant/${minor_version}"
mkdir -p $output_dir
case "${operatingsystem}" in
  archlinux|gentoo)
    output_file="${output_dir}/${operatingsystem}-${hardwaremodel}.facts"
    ;;
  openbsd)
    output_file="${output_dir}/${operatingsystem}-${operatingsystemrelease}-${hardwaremodel}.facts"
    ;;
  *)
    output_file="${output_dir}/${operatingsystem}-${operatingsystemmajrelease}-${hardwaremodel}.facts"
    ;;
esac

case "${operatingsystem}" in
  redhat)
    case "${operatingsystemmajrelease}" in
      5)
        curl "https://yum.puppetlabs.com/puppetlabs-release-pc1-el-${operatingsystemmajrelease}.noarch.rpm" > /tmp/puppetlabs-release-pc1.rpm
        rpm -ivh /tmp/puppetlabs-release-pc1.rpm ;;
      *)
        rpm -ivh "https://yum.puppetlabs.com/puppetlabs-release-pc1-el-${operatingsystemmajrelease}.noarch.rpm"
        yum -y install puppet-agent
        ;;
    esac

    /opt/puppetlabs/bin/facter -j | tee $output_file
    ;;
  debian|ubuntu)
    [ $lsbdistcodename = "lucid" ] && exit # puppet-agent is not supported on lucid
    wget "https://apt.puppetlabs.com/puppetlabs-release-pc1-${lsbdistcodename}.deb" -O /tmp/puppetlabs-release-pc1.deb
    dpkg --install /tmp/puppetlabs-release-pc1.deb
    apt-get update
    apt-get -y install puppet-agent
    /opt/puppetlabs/bin/facter -j | tee $output_file
    ;;
esac
