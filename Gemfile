# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

gem 'facter', ENV.fetch('FACTER_GEM_VERSION', nil), require: false

group :release do
  gem 'faraday-retry', '~> 2.1', require: false
  gem 'github_changelog_generator', '~> 1.16.4', require: false
end

# openvox on Ruby 3.3 / 3.4 has some missing dependencies
# Will be fixed in a future openvox release
gem 'base64', '~> 0.2' if RUBY_VERSION >= '3.4'
gem 'puppet', '>= 7', '< 9'
gem 'racc', '~> 1.8' if RUBY_VERSION >= '3.3'
gem 'syslog', '~> 0.3' if RUBY_VERSION >= '3.4'
