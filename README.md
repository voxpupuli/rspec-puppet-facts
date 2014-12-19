rspec-puppet-facts
==================

Based on an original idea from [apenney](https://github.com/apenney/puppet_facts/).

Simplify your unit tests by looping on every supported Operating System and populating facts.

Before
------

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
      
      it { should compile.with_all_deps }
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
      
      it { should compile.with_all_deps }
      ...
    end
  end
  
  ...
end
```

After
-----

```ruby
require 'spec_helper'

describe 'myclass' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      
      it { should compile.with_all_deps }
      ...
      case facts[:osfamily]
      when 'Debian'
        ...
      when 'RedHat'
        ...
      end
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
    :supported_os   => ['debian-7', 'redhat-6']
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      
      it { should compile.with_all_deps }
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
      
      it { should compile.with_all_deps }
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

Operating Systems supported
---------------------------

             | 1.6 | 1.7 | 2.0 | 2.1 | 2.2 | 2.3
-------------|-----|-----|-----|-----|-----|-----
CentOS 5     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
CentOS 6     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
CentOS 7     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Debian 6     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Debian 7     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Debian 8     |  N  |  N  |  Y  |  Y  |  Y  |  Y
Fedora 19    |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Oracle 5     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Oracle 6     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Oracle 7     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
RedHat 5     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
RedHat 6     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
RedHat 7     |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Scientific 5 |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Scientific 6 |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Scientific 7 |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Ubuntu 12.04 |  Y  |  Y  |  Y  |  Y  |  Y  |  Y
Ubuntu 14.04 |  Y  |  Y  |  Y  |  Y  |  Y  |  Y

Add new Operating System support
--------------------------------

There is `Vagrantfile` to automagically populate `facts` directory by spawning a new VM and launches a provisioning scripts.

```
$ vagrant up
$ vagrant destroy
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
