rspec-puppet-facts
==================

[![Build Status](https://img.shields.io/travis/mcanevet/rspec-puppet-facts/master.svg)](https://travis-ci.org/mcanevet/rspec-puppet-facts)
[![Code Climate](https://img.shields.io/codeclimate/github/mcanevet/rspec-puppet-facts.svg)](https://codeclimate.com/github/mcanevet/rspec-puppet-facts)
[![Gem Version](https://img.shields.io/gem/v/rspec-puppet-facts.svg)](https://rubygems.org/gems/rspec-puppet-facts)
[![Gem Downloads](https://img.shields.io/gem/dt/rspec-puppet-facts.svg)](https://rubygems.org/gems/rspec-puppet-facts)
[![Coverage Status](https://img.shields.io/coveralls/mcanevet/rspec-puppet-facts.svg)](https://coveralls.io/r/mcanevet/rspec-puppet-facts?branch=master)

Based on an original idea from [apenney](https://github.com/apenney/puppet_facts/).

Simplify your unit tests by looping on every supported Operating System and populating facts.

Testing a class or define
-------------------------

### Before

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

### After

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

Testing a type or provider
--------------------------

### Before

```ruby
require 'spec_helper'

describe Puppet::Type.type(:mytype) do

  context "on debian-7-x86_64" do
    before :each do
      Facter.clear
      Facter.stubs(:fact).with(:osfamily).returns Facter.add(:osfamily) { setcode { 'Debian' } }
      Facter.stubs(:fact).with(:operatingsystem).returns Facter.add(:operatingsystem) { setcode { 'Debian' } }
      Facter.stubs(:fact).with(:operatingsystemmajrelease).returns Facter.add(:operatingsystemmajrelease) { setcode { '7' } }
    end
    ...
  end

  context "on redhat-7-x86_64" do
    before :each do
      Facter.clear
      Facter.stubs(:fact).with(:osfamily).returns Facter.add(:osfamily) { setcode { 'RedHat' } }
      Facter.stubs(:fact).with(:operatingsystem).returns Facter.add(:operatingsystem) { setcode { 'RedHat' } }
      Facter.stubs(:fact).with(:operatingsystemmajrelease).returns Facter.add(:operatingsystemmajrelease) { setcode { '7' } }
    end
    ...
  end
end

```

### After

```ruby
require 'spec_helper'

describe Puppet::Type.type(:mytype) do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      before :each do
        Facter.clear
        facts.each do |k, v|
          Facter.stubs(:fact).with(k).returns Facter.add(k) { setcode { v } }
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

Testing a function
------------------

### Before

```ruby
require 'spec_helper'

describe Puppet::Parser::Functions.function(:myfunction) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  context "on debian-7-x86_64" do
    before :each do
      scope.stubs(:lookupvar).with('::osfamily').returns('Debian')
      scope.stubs(:lookupvar).with('osfamily').returns('Debian')
      scope.stubs(:lookupvar).with('::operatingsystem').returns('Debian')
      scope.stubs(:lookupvar).with('operatingsystem').returns('Debian')
      ...
    end
    ...
  end

  context "on redhat-7-x86_64" do
    before :each do
      scope.stubs(:lookupvar).with('::osfamily').returns('RedHat')
      scope.stubs(:lookupvar).with('osfamily').returns('RedHat')
      scope.stubs(:lookupvar).with('::operatingsystem').returns('RedHat')
      scope.stubs(:lookupvar).with('operatingsystem').returns('RedHat')
      ...
    end
    ...
  end
end
```

### After

```ruby
require 'spec_helper'

describe Puppet::Parser::Functions.function(:myfunction) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      before :each do
        facts.each do |k, v|
          scope.stubs(:lookupvar).with("::#{k}").returns(v)
          scope.stubs(:lookupvar).with(k).returns(v)
        end
      end
    end

    ...

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
------------------

You can locally override facts in your spec:

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

You can also globally set facts in `spec/spec_helper.rb`

  * Simple:

    ```ruby
    add_custom_fact :concat_basedir, '/doesnotexist'
    ```

  * Confine to an OS:

    ```ruby
    add_custom_fact :root_home, '/root', :confine => 'redhat-7-x86_64'
    ```

  * Exclude an OS:

    ```ruby
    add_custom_fact :root_home, '/root', :exclude => 'redhat-7-x86_64'
    ```
  * Call a proc to get a value:

    ```ruby
    add_custom_fact :root_home, ->(_os,facts) { "/tmp/#{facts['hostname']}" }
    ```

  * Load facts directly from YAML file in <module>/spec and confined/excluded as above

     ```ruby
      # Assign fact import to variable as a constant
      # Ensure File is in <module>/spec dir and is prefaced with 'spec' i.e. 'spec/<file>'
      GLOBAL_FACTS = add_custom_facts_from_yaml 'spec/<yml_file>'
     ```
  * Facts loaded from YAML can then be referenced in spec tests as:

    ```ruby
    GLOBAL_FACTS['<fact_name>']
    ```

Usage
-----

Add this in your Gemfile:

```ruby
gem 'rspec-puppet-facts', :require => false
```

Add this is your `spec/spec_helper.rb`:

```ruby
require 'rspec-puppet-facts'
include RspecPuppetFacts
```

Run the tests:

```bash
rake spec
```

Run the tests only on some of the facts sets:

```bash
SPEC_FACTS_OS='ubuntu-14' rake spec
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
