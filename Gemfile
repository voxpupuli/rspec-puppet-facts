source ENV['GEM_SOURCE'] || "https://rubygems.org"

gemspec

gem 'mcollective-client',      :require => false

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end
