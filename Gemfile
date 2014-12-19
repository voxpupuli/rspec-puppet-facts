source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'test-unit', :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end
