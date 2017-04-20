rspec-puppet-facts
==================

[![Build Status](https://img.shields.io/travis/mcanevet/rspec-puppet-facts/master.svg)](https://travis-ci.org/mcanevet/rspec-puppet-facts)
[![Code Climate](https://img.shields.io/codeclimate/github/mcanevet/rspec-puppet-facts.svg)](https://codeclimate.com/github/mcanevet/rspec-puppet-facts)
[![Gem Version](https://img.shields.io/gem/v/rspec-puppet-facts.svg)](https://rubygems.org/gems/rspec-puppet-facts)
[![Gem Downloads](https://img.shields.io/gem/dt/rspec-puppet-facts.svg)](https://rubygems.org/gems/rspec-puppet-facts)
[![Coverage Status](https://img.shields.io/coveralls/mcanevet/rspec-puppet-facts.svg)](https://coveralls.io/r/mcanevet/rspec-puppet-facts?branch=master)

Based on an original idea from [apenney](https://github.com/apenney/puppet_facts/),
this gem provides a method of running your [rspec-puppet](https://github.com/rodjek/rspec-puppet)
tests against the facts for all your supported operating systems (provided by
[facterdb](https://github.com/camptocamp/facterdb). This allows you to simplify
your unit tests by removing the need for you to specify the facts yourself.

Installation
------------
If you're using Bundler to manage gems in your module repository, you can 
install rspec-puppet-facts by adding following line to your `Gemfile` and
then running `bundle install`.

```ruby
gem 'rspec-puppet-facts', '~> 1.7', :require => false
```

If you're not using Bundler, you can install rspec-puppet-facts using RubyGems.

```
$ gem install rspec-puppet-facts
```

Once the gem is installed (using either method), you'll need to make the gem
available to rspec by adding the following lines near the top of your
`spec/spec_helper.rb` file.

```ruby
require 'rspec-puppet-facts'
include RspecPuppetFacts
```

Specifying the supported operating systems
------------------------------------------

In order to know which facts to run your tests against, rspec-puppet-facts
needs to know which operating systems your module supports. It does this by
reading the `metadata.json` file at the root of your module. You can read
the documentation for this file [here](https://docs.puppet.com/puppet/latest/modules_metadata.html)

By default rspec-puppet-facts will only provide the facts for `x86_64`
architecture, but this and the supported operating system list can be
overridden by passing a hash to `on_supported_os` in your tests. This hash
is expected to contain either or both of the following two keys:

  * `:hardwaremodels` - An array of hardware architecture names as strings.
  * `:supported_os`   - An array of hashes representing the operating systems.
                        **Note: the keys of these hashes must be strings**
    * `'operatingsystem'`        - The name of the operating system as a string.
    * `'operatingsystemrelease'` - An array of version numbers as strings.

This is particularly useful if your module is split into operating system
subclasses. For example, if you had a class called `myclass::debian` that
you wanted to test against Debian 6 and Debian 7 on both x86\_64 and i386
architectures, you could write the following test:

```ruby
require 'spec_helper'

describe 'myclass::debian' do
  test_on = {
    :hardwaremodels => ['x86_64', 'i386'],
    :supported_os   => [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['6', '7'],
      },
    ],
  }

  on_supported_os(test_on).each do |os, facts|
    it { is_expected.to compile.with_all_deps }
  end
end
```

Usage
-----

As mentioned earlier, rspec-puppet-facts removes the need for you to manually
specify facts for all the different operating systems that your module supports
in your unit tests. Whereas previously you might have written tests like this:

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
    end

    it { is_expected.to compile.with_all_deps }
    ...
  end

  context "on redhat-6-x86_64" do
    let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemmajrelease => '6',
        ...
      }
    end

    it { is_expected.to compile.with_all_deps }
    ...
  end

  ...
end
```

Using rspec-puppet-facts, you can simplify these tests and remove a lot of
duplicate code by using the `on_supported_os` iterator to loop through all the
supported operating systems.

Each iteration of `on_supported_os` provides two variables to your tests (the
names of which are specified by the values between the pipe (`|`) characters.

  * The first value is the name of the fact set. This is made from the values
    of the operatingsystem, operatingsystemmajrelease, and architecture facts
    separated by dashes (e.g. debian-7-x86_64).
  * The second value is the facts for that combination of operatingsystem,
    release and architecture.

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

      # If you need any to specify any operating system specific tests
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

Similarly to when testing manifests, you can use rspec-puppet-facts to simplify
your type and provider unit tests as well. Instead of writing tests like:

```ruby
require 'spec_helper'

describe 'mytype' do

  context "on debian-7-x86_64" do
    let(:facts) do
      {
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Debian',
        :operatingsystemmajrelease => '7',
      }
    end

    it { should be_valid_type }
    ...
  end

  context "on redhat-7-x86_64" do
    let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemmajrelease => '7',
      }
    end

    it { should be_valid_type }
    ...
  end
end

```

You can again use the `on_supported_os` iterator to loop through all your
supported operating systems to remove the duplicate code from your tests and
end up with something like:

```ruby
require 'spec_helper'

describe 'mytype' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should be_valid_type }
      ...

      # If you need to specify any operating system specific tests
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

Just like when testing manifests, types, or providers, you can use
rspec-puppet-facts to simplify your function unit tests. Instead of writing
tests like:

```ruby
require 'spec_helper'

describe 'myfunction' do
  context "on debian-7-x86_64" do
    let(:facts) do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        ...
      }
    end

    it { should run.with_params('something').and_return('a value') }
    ...
  end

  context "on redhat-7-x86_64" do
    let(:facts) do
      {
        :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat',
        ...
      }
    end

    it { should run.with_params('something').and_return('a value') }
    ...
  end
end
```

You can instead simplify your tests to something like:

```ruby
require 'spec_helper'

describe 'myfunction' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should run.with_params('something').and_return('a value') }
      ...
    end
  end
end
```

Overriding fact values
----------------------

You can override fact values and include additional facts is your tests by
merging these values with the facts hash provided by each iteration of
`on_supported_os`.

```ruby
require 'spec_helper'

describe 'myclass' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do

      # Add the 'foo' fact with the value 'bar' to the tests
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

You can also globally set custom fact values in your `spec/spec_helper.rb` file
so that they are automatically available to all of your unit tests using
`on_supported_os`. This is done using the `add_custom_fact` function by passing
it the fact name and then the value.


```ruby
require 'rspec-puppet'
require 'rspec-puppet-facts'
include RspecPuppetFacts

# Add the 'concat_basedir' fact to all tests
add_custom_fact :concat_basedir, '/doesnotexist'

RSpec.configure do |config|
  # normal rspec-puppet configuration
  ...
end
```

These custom facts can be confined so that they are only added to the facts for
specific operating systems

```ruby
add_custom_fact :root_home, '/root', :confine => 'redhat-7-x86_64'
```

Similarly, the custom facts can be confined so that they are added to the facts
for all operating systems except specific ones

```ruby
add_custom_fact :root_home, '/root', :exclude => 'redhat-7-x86_64'
```

In addition to the static fact values shown in the previous examples, you can
pass a lambda as the value for the custom fact in order to create dynamic
values. For example, if you wanted to define a global custom fact that uses the
value of another fact, you can do that with a lambda. The lambda will be passed
the same operating system name and fact values that your tests are provided by
`on_supported_os`.

```ruby
add_custom_fact :root_home, lambda { |os,facts| "/tmp/#{facts['hostname']" }
```

Running your tests
------------------

For most cases, there is no change to how you run your tests. Running `rake
spec` will run all the tests against the facts for all the supported
operating systems.

If you want to run the tests against the facts for specific operating systems,
you can provide a filter in the `SPEC_FACTS_OS` environment variable and only
the supported operating systems whose name starts with the specified filter
will be used.

```bash
SPEC_FACTS_OS='ubuntu-14' rake spec
```
