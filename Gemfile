source ENV['GEM_SOURCE'] || "https://rubygems.org"

gemspec

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

gem 'json', '~> 1.0', {"platforms"=>["ruby_18", "ruby_19"]}
