require 'coveralls'
Coveralls.wear!

require 'rspec'
require 'mocha/api'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |config|
     config.mock_framework = :mocha
end
