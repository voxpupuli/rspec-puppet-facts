source ENV['GEM_SOURCE'] || "https://rubygems.org"

gemspec

gem 'mcollective-client',      :require => false

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

platforms :ruby_18, :ruby_19 do
  gem 'json', '~> 1.0'
  gem 'json_pure', '~> 1.0'
  gem 'tins', '~> 1.6.0'
end
