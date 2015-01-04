# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec-puppet-facts/version"

Gem::Specification.new do |s|
  s.name        = "rspec-puppet-facts"
  s.version     = RspecPuppetFacts::Version::STRING
  s.authors     = ["Mickaël Canévet"]
  s.email       = ["mickael.canevet@camptocamp.com"]
  s.homepage    = "http://github.com/mcanevet/rspec-puppet-facts"
  s.summary     = "Standard facts fixtures for Puppet"
  s.description = "Contains facts from many Facter version on many Operating Systems"
  s.licenses    = 'Apache-2.0'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_development_dependency 'coveralls', '~> 0.7'
  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_runtime_dependency 'json', '~> 1.8'
  s.add_runtime_dependency 'facter', '~> 1.6'
end
