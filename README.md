rspec-puppet-facts
==================

Based on an original idea from [apenney](https://github.com/apenney/puppet_facts/).

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

  on_supported_os(['debian-7-amd64', 'redhat-6-amd64']).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      
      ...
    end
  end
end
```
