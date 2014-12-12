#!/bin/bash

# Install latest version of facter 
gem install bundler
bundle install --path vendor/bundler
operatingsystem=$(bundle exec facter operatingsystem | tr '[:upper:]' '[:lower:]')
operatingsystemmajrelease=$(bundle exec facter operatingsystemmajrelease)
hardwaremodel=$(bundle exec facter hardwaremodel)

for version in 1.6.0 1.7.0 2.0.0 2.1.0 2.2.0 2.3.0; do
  FACTER_GEM_VERSION="~> ${version}" bundle update
  minor_version=$(echo $version | cut -c1-3)
  output_dir="/vagrant/facts/${minor_version}"
  mkdir -p $output_dir
  FACTER_GEM_VERSION="~> ${version}" bundle exec facter | tee "${output_dir}/${operatingsystem}-${operatingsystemmajrelease}-${hardwaremodel}.facts"
done
