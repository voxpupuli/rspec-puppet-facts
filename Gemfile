source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

gem 'facter', ENV['FACTER_GEM_VERSION'], :require => false

group :release do
  gem 'github_changelog_generator', require: false
end

group :coverage, optional: ENV['COVERAGE']!='yes' do
  gem 'codecov', :require => false
  gem 'simplecov-console', :require => false
end
