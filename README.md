rspec-puppet-facts
==================

[![License](https://img.shields.io/github/license/voxpupuli/rspec-puppet-facts.svg)](https://github.com/voxpupuli/rspec-puppet-facts/blob/master/LICENSE)
[![Test](https://github.com/voxpupuli/rspec-puppet-facts/actions/workflows/test.yml/badge.svg)](https://github.com/voxpupuli/rspec-puppet-facts/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/voxpupuli/rspec-puppet-facts/branch/master/graph/badge.svg)](https://codecov.io/gh/voxpupuli/rspec-puppet-facts)
[![Release](https://github.com/voxpupuli/rspec-puppet-facts/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/rspec-puppet-facts/actions/workflows/release.yml)
[![RubyGem Version](https://img.shields.io/gem/v/rspec-puppet-facts.svg)](https://rubygems.org/gems/rspec-puppet-facts)
[![RubyGem Downloads](https://img.shields.io/gem/dt/rspec-puppet-facts.svg)](https://rubygems.org/gems/rspec-puppet-facts)
[![Donated by Camptocamp](https://img.shields.io/badge/donated%20by-camptocamp-fb7047.svg)](#transfer-notice)

Based on an original idea from [apenney](https://github.com/apenney/puppet_facts/),
this gem provides a method of running your [rspec-puppet](https://github.com/puppetlabs/rspec-puppet)
tests against the facts for all your supported operating systems (provided by
[facterdb](https://github.com/voxpupuli/facterdb)).
This simplifies unit testing because you don't need to specify the facts yourself.

## Installation

If you're using Bundler to manage gems in your module repository, install `rspec-puppet-facts` by adding it to the Gemfile.

1. Add the following line to your `Gemfile`:

```ruby
gem 'rspec-puppet-facts', require: false
```

2. Run `bundle install`.

If you're not using Bundler, install the `rspec-puppet-facts` manually.

1. On the command line, run:

```bash
$ gem install rspec-puppet-facts
```

After the gem is installed (using either method), make the gem available to rspec by adding the following lines in your `spec/spec_helper.rb` file. Place the lines after `require 'rspec-puppet'` and before the `RSpec.configure` block, if one exists.

```ruby
require 'rspec-puppet-facts'
include RspecPuppetFacts
```

## Specifying the supported operating systems

To determine which facts to run your tests against, `rspec-puppet-facts` checks your module's `metadata.json` to find out what operating systems your module supports. The `metadata.json` file is located in the root of your module. To learn more about this file, see Puppet's [metadata](https://help.puppet.com/core/current/Content/PuppetCore/modules_metadata.htm) documentation.

By default, `rspec-puppet-facts` provides the facts only for `x86_64` architecture. However, you can override this default and the supported operating system list by passing a hash to `on_supported_os` in your tests. This hash must contain either or both of the following keys:

  * `:hardwaremodels` - An array of hardware architecture names, as strings.
  * `:supported_os`   - An array of hashes representing the operating systems.
                        **Note: the keys of these hashes must be strings**
    * `'operatingsystem'`        - The name of the operating system, as a string.
    * `'operatingsystemrelease'` - An array of version numbers, as strings.

This is particularly useful if your module is split into operating system subclasses. For example, if you had a class called `myclass::debian` that you wanted to test against Debian 12 and Debian 11 on both `x86_64` _and_ `i386` architectures, you could write the following test:

```ruby
require 'spec_helper'

describe 'myclass::raspbian' do
  test_on = {
    hardwaremodels: ['x86_64', 'i386'],
    supported_os: [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['12', '11'],
      },
    ],
  }
  on_supported_os(test_on).each do |os, os_facts|
    let(:facts) { os_facts }
    it { is_expected.to compile.with_all_deps }
  end
end
```

## Specifying a default Facter version

By default, `on_supported_os` will return the facts for the version of Facter that it has loaded. It will check for the loaded Puppet version and maps that to the Facter version that Perforce released in the matching AIO.
The mapping is stored in `ext/puppet_agent_components.json` (check the [maintenance](#maintenance) section for details) and computated in the `facter_version_for_puppet_version` method.
This behaviour can be overridden by setting the `default_facter_version` RSpec setting in your `spec/spec_helper.rb` file.

```ruby
RSpec.configure do |c|
  c.default_facter_version = '3.14.0'
end
```

## Symbolized vs stringified facts

For a long long time, the first level of keys in a factsets were symbols.
This was fine before there were structured facts, but structured facts ended up as nested hashes that always had strings.
This doesn't make sense and easy to get wrong.
The original data contains only strings so conversion actually costs performance.

The option to switch between symbolized vs stringified facts was introduced in [25634f4481f20f2fc7444e867928ca607234e33e](https://github.com/voxpupuli/rspec-puppet-facts/commit/25634f4481f20f2fc7444e867928ca607234e33e) (Release [1.9.5](https://github.com/voxpupuli/rspec-puppet-facts/blob/master/CHANGELOG.md#2019-07-29---release-195)), but version 5.0.0 has resolved various implementation bugs.

This can be configured like this:

```ruby
RSpec.configure do |c|
  c.facterdb_string_keys = false
end
```

In the 5.x release series of rspec-puppet-facts the default `false` is deprecated.
With the 6.0.0 release we will flip it to `true` (https://github.com/voxpupuli/rspec-puppet-facts/pull/189).

You may have the following rspec-puppet test using deprecated symbolized facts:

```ruby
on_supported_os.each do |os, os_facts|
  case os_facts[:os]['name']
  when 'Archlinux'
    context 'on Archlinux' do
      it { is_expected.to contain_package('borg') }
    end
  when 'Ubuntu'
  end
end
```

With the string facts, the same test looks like:

```ruby
on_supported_os.each do |os, os_facts|
  case os_facts['os']['name']
  when 'Archlinux'
    context 'on Archlinux' do
      it { is_expected.to contain_package('borg') }
    end
  when 'Ubuntu'
  end
end
```

## Usage

Use the `on_supported_os` iterator to loop through all of your module's supported operating systems. This allows you to simplify your tests and remove a lot of duplicate code.

Each iteration of `on_supported_os` provides two variables to your tests. (In the code examples below, these variables are specified by the values between the pipe (`|`) characters.)

  * The first value is the name of the fact set. This is made from the values of the operatingsystem, operatingsystemmajrelease, and architecture facts separated by dashes (for example, 'debian-7-x86_64').
  * The second value is the facts for that combination of operating system, release, and architecture.

For example, previously, you might have written a test that specified Debian 7 and Red Hat 6 as the supported modules:

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

With `on_supported_os` iteration, you can rewrite this test to loop over each of the supported operating systems without explicitly specifying them:

```ruby
require 'spec_helper'

describe 'myclass' do

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      it { is_expected.to compile.with_all_deps }
      ...

      # If you need any to specify any operating system specific tests
      case os_facts[:osfamily]
      when 'Debian'
        ...
      else
        ...
      end
    end
  end
end
```

When using roles and profiles to manage a heterogeneous IT estate, you can test a profile that supports several OSes with many `let(:facts)` as long as each is in its own context:
```ruby
require 'spec_helper'

describe 'profiles::packagerepos' do
  context 'Raspbian tests' do # We manage hundreds of desk-mounted Pis
    raspbian = {
      hardwaremodels: ['armv7l'],
      supported_os: [
        {
          'operatingsystem'        => 'Debian',
          'operatingsystemrelease' => ['10', '9', '8'],
        },
      ],
    }
    on_supported_os(raspbian).each do |os, os_facts|
      let(:facts) do
        os_facts
      end

      context "#{os} with defaults" do
        it { is_expected.to compile }
        # more tests ...
      end
    end
  end
  context 'Ubuntu tests' do # And also a fleet of Ubuntu desktops
    ubuntu = {
      supported_os: [
        {
          'operatingsystem'        => 'Ubuntu',
          'operatingsystemrelease' => ['18.04', '16.04'],
        },
      ],
    }

    on_supported_os(ubuntu).each do |os, os_facts|
      let(:facts) do
        os_facts
      end

      context "#{os} with defaults" do
        it { is_expected.to compile }
        # more tests ...
      end
    end
  end
end
```

### Testing a type or provider

Use `on_supported_os` in the same way for your type and provider unit tests.

**Specifying each operating system**:

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

**Looping with `on_supported_os` iterator**:

```ruby
require 'spec_helper'

describe 'mytype' do

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      it { should be_valid_type }
      ...

      # If you need to specify any operating system specific tests
      case os_facts[:osfamily]
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

### Testing a function

As with testing manifests, types, or providers, `on_supported_os` iteration simplifies your function unit tests.

**Specifying each operating system**:

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

**Looping with `on_supported_os` iterator**:

```ruby
require 'spec_helper'

describe 'myfunction' do

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      it { should run.with_params('something').and_return('a value') }
      ...
    end
  end
end
```

### Adding custom fact values

By adding custom fact values, you can:

* Override fact values
* Include additional facts in your tests.
* Add global custom facts for all of your unit tests
* Add custom facts to only certain operating systems
* Add custom facts to all operating systems _except_ specific operating systems
* Create dynamic values for custom facts by setting a lambda as the value.

#### Override and add facts

To override fact values and include additional facts in your tests, merge values with the facts hash provided by each iteration of `on_supported_os`.

```ruby
require 'spec_helper'

describe 'myclass' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do

      # Add the 'foo' fact with the value 'bar' to the tests
      let(:facts) do
        os_facts.merge({
          :foo => 'bar',
        })
      end

      it { is_expected.to compile.with_all_deps }
      ...
    end
  end
end
```

#### Set global custom facts

Set global custom fact values in your `spec/spec_helper.rb` file so that they are automatically available to all of your unit tests using `on_supported_os`.

Pass the fact name and value to the `add_custom_fact` function:

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

#### Confine custom facts

To add custom facts for only certain operating systems, set `confine` with the operating system as a string value:

```ruby
add_custom_fact :root_home, '/root', :confine => 'redhat-7-x86_64'
```

To add custom facts for all operating systems _except_ specific ones, set `exclude` with the operating system as a string value:

```ruby
add_custom_fact :root_home, '/root', :exclude => 'redhat-7-x86_64'
```

#### Create dynamic facts

In addition to the static fact values shown in the previous examples, you can create dynamic values.

To do this, pass a lambda as the value for the custom fact. The lambda is passed the same values for operating system name and fact values that your tests are provided by `on_supported_os`.

```ruby
add_custom_fact :root_home, lambda { |os,facts| "/tmp/#{facts['hostname']}" }
```

#### Merge into existing facts

You can also supply an optional input `:merge_facts` to the `add_custom_fact` method.

This allows you to merge facts values into a fact, if the fact is already present in the facts hash as oppose to overwriting the fact value.

```ruby
add_custom_fact :identity, { 'user' => 'test_user' }, merge_facts: true
```

Will result in a hash of the identity fact like the below:

```ruby
{
  "gid"=>0,
  "group"=>"root",
  "privileged"=>true,
  "uid"=>0,
  "user"=>"test_user"
}
```

### Supplying Custom External Facts through FacterDB
Rspec-puppet-facts uses a gem called facterdb that contains many fact sets of various combinations that are pre generated.  Rspec-puppet-facts queries
facterdb to pull out a specific fact set to use when testing.

The default facts are great for many things but there will be times when you need to have custom
fact sets that only make sense in your environment or might contain sensitive information.

To supply external facts to facterdb just set the `FACTERDB_SEARCH_PATHS` environment variable with one or more
paths to your facts.

When separating paths please use the default path separator character supported by your OS.
* Unix/Linux/OSX = `:`
* Windows = `;`

This means you will need to supply your own fact sets in addition to the ones contained in facterdb.
So each fact set you create must meet the following requirements:

1. A JSON serialized file containing a single Hash of all the facts.
2. The facts file must end in `.facts`
3. Must be placed inside some directory.  You can organize this directory however you like.

[Example file](https://github.com/camptocamp/facterdb/blob/master/facts/3.5/oraclelinux-5-i386.facts)

Facterdb is smart enough the search your supplied directories for files ending with '.facts'.  You can even supply
multiple directories.

Example:

`FACTERDB_SEARCH_PATHS="/var/opt/lib/custom_facts"`

or

`FACTERDB_SEARCH_PATHS="/var/opt/lib/custom_facts:/tmp/custom_facts:/home/user1/custom_facts"`


You can create these files via many methods.

* `puppet facts | jq '.values' > /tmp/custom_facts/datacenter_a/2.4/os_x.facts`  # must have jq command
* Via puppetdb queries
* hand crafted


Additionally you can skip the default FacterDB facts completely by setting the environment variable `FACTERDB_SKIP_DEFAULTDB`.
This will instruct facterdb to not look at its built-in facts which can be useful should you need to completely replace which facts are used.


Setting the variable `FACTERDB_SKIP_DEFAULTDB` to anything will disable the internal facts used by facterdb.  You would most likely use this in combination
with the `FACTERDB_SEARCH_PATHS` environment variable.

Example:

```
FACTERDB_SEARCH_PATHS="/var/opt/lib/custom_facts:/tmp/custom_facts:/home/user1/custom_facts"
FACTERDB_SKIP_DEFAULTDB='yes'
```

We recommend placing custom external facts under spec/fixtures/facts directory.

Additionally, if you plan on using these custom facts everytime you should set the following in your spec helper.

```ruby
module_spec_dir = File.dirname(__FILE__)
custom_facts = File.join(module_spec_dir, 'fixtures', 'facts')
ENV['FACTERDB_SEARCH_PATHS'] = custom_facts
```
## Running your tests

For most cases, there is no change to how you run your tests. Running `rake spec` will run all the tests against the facts for all the supported operating systems.  If you are developing a module using the [Puppet Development Kit](https://puppet.com/docs/pdk/3.x/pdk_install.html), `pdk test unit` will run all your tests against the supported operating systems listed in `metadata.json`.

If you want to run the tests against the facts for specific operating systems, you can provide a filter in the `SPEC_FACTS_OS` environment variable and only the supported operating systems whose name starts with the specified filter will be used.

```bash
SPEC_FACTS_OS='ubuntu-14' rake spec
```

When no facts are available for the specific facter/operating system combination, the library will fall back to facts from earlier versions of the requested operating system, to allow testing to continue when new versions of facter are released. Set `SPEC_FACTS_STRICT=yes` to instead trigger a failure.

## Maintenance

This gem uses information about puppet AIO component versions to build/test.
They are stored at `ext/puppet_agent_facter_versions.json`.

In the past we used `bundle exec rake puppet_versions:update` to update the file and `puppet_versions:test` to validate it.
This relied on information from the puppet forge.
With the 6.0.0 release we're switching to openvox.
The file is currently maintained by hand, because openvox doesn't offer an API yet to map agent releases to openfact releases.
It got also renamed from `ext/puppet_agent_facter_versions.json` -> `ext/openvox_agent_facter_versions.json`.

**`ext/openvox_agent_facter_versions.json`now lists a mapping of openvox releases to openfact releases**

## License

This project is licensed under the [Apache-2 license](./LICENSE).

## Transfer Notice

This plugin was originally authored by [Camptocamp](http://www.camptocamp.com).
The maintainer preferred that Puppet Community take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here instead of Camptocamp.

Previously: https://github.com/mcanevet/rspec-puppet-facts

## Release information

To make a new release, please do:
* Update the version in the `lib/rspec-puppet-facts/version.rb` file
* Install gems with `bundle install --with release --path .vendor`
* generate the changelog with `bundle exec rake changelog`
* Create a PR with it
* After it got merged, push a tag. A github workflow will do the actual release
