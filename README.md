rspec-puppet-facts
==================

Based on an original idea from [apenney](https://github.com/apenney/puppet_facts/).

Usage
-----

Add this in your Gemfile:

```ruby
gem 'rspec-puppet-facts', :require => false
```

Add some `facter` version to test in your .travis.yml

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

Add this is your spec/spec_helper.rb:

```ruby
require 'rspec-puppet-facts'
include RspecPuppetFacts
```

Then in your unit tests:

```ruby
require 'spec_helper'

describe 'openldap::server' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      
      ...
    end
  end
end
```
By default rspec-puppet-facts looks at your `metadata.json` to find supported operating systems, but you can specify for each context which ones you want to use:

```ruby
require 'spec_helper'

describe 'openldap::server' do

  on_supported_os(['debian-7-x86_64', 'redhat-6-x86_64']).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      
      ...
    end
  end
end
```

Add additional facts:
```ruby
require 'spec_helper'

describe 'openldap::server' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :foo => 'bar',
        })
      end
      
      ...
    end
  end
end
```
Add new facts
-------------

There is `Vagrantfile` to automagically populate `facts` directory by spawning a new VM and launches a provisioning scripts.

```
$ vagrant up
$ vagrant destroy
```

Create i386 facts from x86_64's ones

```
for file in facts/*/*-x86_64.facts; do cat $file | sed -e 's/x86_64/i386/' -e 's/amd64/i386/' > $(echo $file | sed 's/x86_64/i386/'); done
```
Create RedHat facts from CentOS's ones

```
for file in facts/*/centos-*.facts; do cat $file | sed -e 's/CentOS/RedHat/' > $(echo $file | sed 's/centos/redhat/'); done
```
