# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'rspec-puppet-facts/version'

Gem::Specification.new do |s|
  s.name        = 'rspec-puppet-facts'
  s.version     = RspecPuppetFacts::Version::STRING
  s.authors     = ['Vox Pupuli']
  s.email       = ['voxpupuli@groups.io']
  s.homepage    = 'http://github.com/voxpupuli/rspec-puppet-facts'
  s.summary     = 'Standard facts fixtures for Puppet'
  s.description = 'Contains facts from many Facter version on many Operating Systems'
  s.licenses    = 'Apache-2.0'

  s.required_ruby_version = '>= 2.7.0'

  s.files       = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.add_development_dependency 'mime-types', '~> 3.5', '>= 3.5.2'
  s.add_development_dependency 'rake', '~> 13.1'
  s.add_development_dependency 'rspec', '~> 3.12'
  s.add_development_dependency 'yard', '~> 0.9.34'

  s.add_development_dependency 'voxpupuli-rubocop', '~> 3.0.0'

  s.add_dependency 'deep_merge', '~> 1.2'
  s.add_dependency 'facter', '< 5'
  s.add_dependency 'facterdb', '~> 3.1'
  s.add_dependency 'puppet', '>= 7', '< 9'
end
