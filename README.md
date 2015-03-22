rspec-puppet-facts
==================

[![Build Status](https://travis-ci.org/mcanevet/rspec-puppet-facts.png?branch=master)](https://travis-ci.org/mcanevet/rspec-puppet-facts)
[![Code Climate](https://codeclimate.com/github/mcanevet/rspec-puppet-facts/badges/gpa.svg)](https://codeclimate.com/github/mcanevet/rspec-puppet-facts)
[![Gem Version](https://badge.fury.io/rb/rspec-puppet-facts.svg)](http://badge.fury.io/rb/rspec-puppet-facts)
[![Coverage Status](https://img.shields.io/coveralls/mcanevet/rspec-puppet-facts.svg)](https://coveralls.io/r/mcanevet/rspec-puppet-facts?branch=master)

Based on an original idea from [apenney](https://github.com/apenney/puppet_facts/).

Simplify your unit tests by looping on every supported Operating System and populating facts.

Before
------

### Testing a class or define

```ruby
require 'spec_helper'

describe 'myclass' do

  context "on debian-7-x86_64" do
    let(:facts) do
      {
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Debian',
        :operatingsystemmajrelease => '7',
        ...
      }
      
      it { is_expected.to compile.with_all_deps }
      ...
    end
  end

  context "on redhat-6-x86_64" do
    let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemmajrelease => '6',
        ...
      }
      
      it { is_expected.to compile.with_all_deps }
      ...
    end
  end
  
  ...
end
```

### Testing a type or provider

```ruby
require 'spec_helper'

describe Puppet::Type.type(:mytype) do

  context "on debian-7-x86_64" do
    before :each do
      Facter.stubs(:value).with(:osfamily).returns 'Debian'
      Facter.stubs(:value).with(:operatingsystem).returns 'Debian'
      Facter.stubs(:value).with(:operatingsystemmajrelease).returns '7'
    end
    ...
  end

  context "on redhat-7-x86_64" do
    before :each do
      Facter.stubs(:value).with(:osfamily).returns 'RedHat'
      Facter.stubs(:value).with(:operatingsystem).returns 'RedHat'
      Facter.stubs(:value).with(:operatingsystemmajrelease).returns '7'
    end
    ...
  end
end

```

After
-----

### Testing a class or define

```ruby
require 'spec_helper'

describe 'myclass' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      
      it { is_expected.to compile.with_all_deps }
      ...
      case facts[:osfamily]
      when 'Debian'
        ...
      else
        ...
      end
    end
  end
end
```
### Testing a type or provider

```ruby
require 'spec_helper'

describe Puppet::Type.type(:mytype) do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      before :each do
        facts.each do |k, v|
          Facter.stubs(:value).with(k).returns v
        end
      end
      ...
      case facts[:osfamily]
      when 'Debian'
        ...
      else
        ...
      end
      ...
    end
  end
end

```

By default rspec-puppet-facts looks at your `metadata.json` to find supported operating systems and tests only with `x86_64`, but you can specify for each context which ones you want to use:

```ruby
require 'spec_helper'

describe 'myclass' do

  on_supported_os({
    :hardwaremodels => ['i386', 'x86_64'],
    :supported_os   => [
      {
        "operatingsystem" => "Debian",
        "operatingsystemrelease" => [
          "6",
          "7"
        ]
      },
      {
        "operatingsystem" => "RedHat",
        "operatingsystemrelease" => [
          "5",
          "6"
        ]
      }
    ],
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      
      it { is_expected.to compile.with_all_deps }
      ...
    end
  end
end
```

Append some facts:

```ruby
require 'spec_helper'

describe 'myclass' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :foo => 'bar',
        })
      end
      
      it { is_expected.to compile.with_all_deps }
      ...
    end
  end
end
```

Usage
-----

Add this in your Gemfile:

```ruby
gem 'rspec-puppet-facts', :require => false
```

Add this is your spec/spec_helper.rb:

```ruby
require 'rspec-puppet-facts'
include RspecPuppetFacts
```

Finaly, Add some `facter` version to test in your .travis.yml

```yaml
...
matrix:
  fast_finish: true
  include:
  - rvm: 1.8.7
    env: PUPPET_GEM_VERSION="~> 2.7.0" FACTER_GEM_VERSION="~> 1.6.0"
  - rvm: 1.8.7
    env: PUPPET_GEM_VERSION="~> 2.7.0" FACTER_GEM_VERSION="~> 1.7.0"
  - rvm: 1.9.3
    env: PUPPET_GEM_VERSION="~> 3.0" FACTER_GEM_VERSION="~> 2.1.0"
  - rvm: 1.9.3
    env: PUPPET_GEM_VERSION="~> 3.0" FACTER_GEM_VERSION="~> 2.2.0"
  - rvm: 2.0.0
    env: PUPPET_GEM_VERSION="~> 3.0"
  allow_failures:
    - rvm: 1.8.7
      env: PUPPET_GEM_VERSION="~> 2.7.0" FACTER_GEM_VERSION="~> 1.6.0"
...
```
Facter versions supported
-------------------------
* 1.6
* 1.7
* 2.0
* 2.1
* 2.2
* 2.3
* 2.4

Operating Systems supported
-----------------------------------------------
* ArchLinux
* CentOS 5
* CentOS 6
* CentOS 7
* Debian 6
* Debian 7
* Debian 8
* Fedora 19
* FreeBSD 9
* FreeBSD 10
* OpenSuse 12
* OpenSuse 13
* Oracle 5
* Oracle 6
* Oracle 7
* RedHat 5
* RedHat 6
* RedHat 7
* Scientific 5
* Scientific 6
* Scientific 7
* SLES 11
* Ubuntu 10.04
* Ubuntu 12.04
* Ubuntu 14.04

Add new Operating System support
--------------------------------

There is `Vagrantfile` to automagically populate `facts` directory by spawning a new VM and launches a provisioning scripts.

```
$ cd facts
$ vagrant up --provision
```

Create i386 facts from x86_64's ones

```
for file in facts/*/*-x86_64.facts; do cat $file | sed -e 's/x86_64/i386/' -e 's/amd64/i386/' > $(echo $file | sed 's/x86_64/i386/'); done
```
Create RedHat, Scientific, OracleLinux facts from CentOS's ones

```
for file in facts/*/centos-*.facts; do cat $file | sed -e 's/CentOS/RedHat/' > $(echo $file | sed 's/centos/redhat/'); done
for file in facts/*/centos-*.facts; do cat $file | sed -e 's/CentOS/Scientific/' > $(echo $file | sed 's/centos/scientific/'); done
for file in facts/*/centos-*.facts; do cat $file | sed -e 's/CentOS/OracleLinux/' > $(echo $file | sed 's/centos/oraclelinux/'); done
```
