# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rspec-puppet-facts/version'

Gem::Specification.new do |s|
  s.name        = 'rspec-puppet-facts'
  s.version     = RspecPuppetFacts::Version::STRING
  s.authors     = ['Mickaël Canévet']
  s.email       = ['mickael.canevet@camptocamp.com']
  s.homepage    = 'http://github.com/mcanevet/rspec-puppet-facts'
  s.summary     = 'Standard facts fixtures for Puppet'
  s.description = 'Contains facts from many Facter version on many Operating Systems'
  s.licenses    = 'Apache-2.0'

  # see .travis.yml for the supported ruby versions
  s.required_ruby_version = '>= 2.1.0'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.add_development_dependency 'mime-types'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
  s.add_runtime_dependency 'puppet'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'facter'
  s.add_runtime_dependency 'facterdb', '>= 0.5.0'
end
