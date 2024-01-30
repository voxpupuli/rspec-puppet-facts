source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

gem 'facter', ENV['FACTER_GEM_VERSION'], :require => false

group :release do
  gem 'faraday-retry', '~> 2.1', require: false
  gem 'github_changelog_generator', '~> 1.16.4', require: false
end

group :coverage, optional: ENV['COVERAGE']!='yes' do
  gem 'codecov', :require => false
  gem 'simplecov-console', :require => false
end
