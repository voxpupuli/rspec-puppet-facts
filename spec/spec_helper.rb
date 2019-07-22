if ENV['COVERAGE']
  require 'coveralls'
  Coveralls.wear!
end

require 'rspec'
require 'rspec-puppet-facts'
include RspecPuppetFacts
