require 'puppet'
require 'facter'
require 'facterdb'
require 'json'
require 'mcollective'

# The purpose of this module is to simplify the Puppet
# module's RSpec tests by looping through all supported
# OS'es and their facts data which is received from the FacterDB.
module RspecPuppetFacts

  def jgrep_filter(supported_os, opts)
    filter = []
    supported_os.map do |os_sup|
      if os_sup['operatingsystemrelease']
        os_sup['operatingsystemrelease'].map do |operatingsystemmajrelease|
          opts[:hardwaremodels].each do |hardwaremodel|

            if os_sup['operatingsystem'] =~ /BSD/
              hardwaremodel = 'amd64'
            elsif os_sup['operatingsystem'] =~ /Solaris/
              hardwaremodel = 'i86pc'
            elsif os_sup['operatingsystem'] =~ /windows/
              hardwaremodel = 'x64'
            end

            filter << {
                :facterversion          => "/^#{Facter.version[0..2]}/",
                :operatingsystem        => os_sup['operatingsystem'],
                :operatingsystemrelease => "/^#{operatingsystemmajrelease.split(' ')[0]}/",
                :hardwaremodel          => hardwaremodel,
            }
          end
        end
      else
        opts[:hardwaremodels].each do |hardwaremodel|
          filter << {
              :facterversion   => "/^#{Facter.version[0..2]}/",
              :operatingsystem => os_sup['operatingsystem'],
              :hardwaremodel   => hardwaremodel,
          }
        end
      end
    end
    filter
  end

  # Use the provided options or the data from the metadata.json file
  # to find a set of matching facts in the FacterDB.
  # OS names and facts can be used in the Puppet RSpec tests
  # to run the examples against all supported facts combinations.
  #
  # The list of received OS facts can also be filtered by the SPEC_FACTS_OS
  # environment variable. For example, if the variable is set to "debian"
  # only the OS names which start with "debian" will be returned. It allows a
  # user to quickly run the tests only on a single facts set without any
  # file modifications.
  #
  # @return [Array<Hash>]
  # @param [Hash] opts
  # @option opts [String,Array<String>] :hardwaremodels The OS architecture names, i.e. x86_64
  # @option opts [Array<Hash>] :supported_os If this options is provided the data
  # will be used instead of the "operatingsystem_support" section if the metadata file
  # even if the file is missing.
  def on_supported_operatingsystem(opts = {})
    opts[:hardwaremodels] ||= ['x86_64']
    opts[:hardwaremodels] = [opts[:hardwaremodels]] unless opts[:hardwaremodels].is_a? Array
    opts[:supported_os] ||= RspecPuppetFacts.meta_supported_os

    os_facts_array = []
    RspecPuppetFacts.facterdb_facts(jgrep_filter(opts[:supported_os], opts)).map do |facts|
      next unless facts[:operatingsystem].downcase.start_with? RspecPuppetFacts.spec_facts_os_filter if RspecPuppetFacts.spec_facts_os_filter
      os_facts_array << facts.merge(RspecPuppetFacts.common_facts)
    end
    os_facts_array
  end

  # Use the provided options or the data from the metadata.json file
  # to find a set of matching facts in the FacterDB.
  # OS names and facts can be used in the Puppet RSpec tests
  # to run the examples against all supported facts combinations.
  #
  # The list of received OS facts can also be filtered by the SPEC_FACTS_OS
  # environment variable. For example, if the variable is set to "debian"
  # only the OS names which start with "debian" will be returned. It allows a
  # user to quickly run the tests only on a single facts set without any
  # file modifications.
  #
  # @return [Hash <String => Hash>]
  # @param [Hash] opts
  # @option opts [String,Array<String>] :hardwaremodels The OS architecture names, i.e. x86_64
  # @option opts [Array<Hash>] :supported_os If this options is provided the data
  # will be used instead of the "operatingsystem_support" section if the metadata file
  # even if the file is missing.
  def on_supported_os(opts = {})
    opts[:hardwaremodels] ||= ['x86_64']
    opts[:hardwaremodels] = [opts[:hardwaremodels]] unless opts[:hardwaremodels].is_a? Array
    opts[:supported_os] ||= RspecPuppetFacts.meta_supported_os

    os_facts_hash = {}
    RspecPuppetFacts.facterdb_facts(jgrep_filter(opts[:supported_os], opts)).map do |facts|
      os = "#{facts[:operatingsystem].downcase}-#{facts[:operatingsystemrelease].split('.')[0]}-#{facts[:hardwaremodel]}"
      next unless os.start_with? RspecPuppetFacts.spec_facts_os_filter if RspecPuppetFacts.spec_facts_os_filter
      facts.merge! RspecPuppetFacts.common_facts
      os_facts_hash[os] = facts
    end
    os_facts_hash
  end

  # If provided this filter can be used to limit the set
  # of retrieved facts only to the matched OS names.
  # The value is being taken from the SPEC_FACTS_OS environment
  # variable and 
  # @return [nil,String]
  # @api private
  def self.spec_facts_os_filter
    ENV['SPEC_FACTS_OS']
  end

  def self.facterdb_facts(filter)
    received_facts = FacterDB::get_facts(filter)
    unless received_facts.any?
      RspecPuppetFacts.warning "No facts were found in the FacterDB for: #{filter.inspect}"
      return {}
    end
    received_facts
  end

  # These facts are common for all OS'es and will be
  # added to the facts retrieved from the FacterDB
  # @api private
  # @return [Hash <Symbol => String>]
  def self.common_facts
    return @common_facts if @common_facts
    @common_facts = {
        :mco_version   => MCollective::VERSION,
        :puppetversion => Puppet.version,
        :rubysitedir   => RbConfig::CONFIG['sitelibdir'],
        :rubyversion   => RUBY_VERSION,
    }
    if Puppet.features.augeas?
      @common_facts[:augeasversion] = Augeas.open(nil, nil, Augeas::NO_MODL_AUTOLOAD).get('/augeas/version')
    end
    @common_facts
  end

  # Get the "operatingsystem_support" structure from
  # the parsed metadata.json file
  # @raise [StandardError] if there is no "operatingsystem_support"
  # in the metadata
  # @return [Array<Hash>]
  # @api private
  def self.meta_supported_os
    unless metadata['operatingsystem_support'].is_a? Array
      fail StandardError, 'Unknown operatingsystem support in the metadata file!'
    end
    metadata['operatingsystem_support']
  end

  # Read the metadata file and parse
  # its JSON content.
  # @raise [StandardError] if the metadata file is missing
  # @return [Hash]
  # @api private
  def self.metadata
    return @metadata if @metadata
    unless File.file? metadata_file
      fail StandardError, "Can't find metadata.json... dunno why"
    end
    content = File.read metadata_file
    @metadata = JSON.parse content
  end

  # This file contains the Puppet module's metadata
  # @return [String]
  # @api private
  def self.metadata_file
    'metadata.json'
  end

  # Print a warning message to the console
  # @param message [String]
  # @api private
  def self.warning(message)
    STDERR.puts message
  end

  # Reset the memoization
  # to make the saved structures
  # be generated again
  # @api private
  def self.reset
    @common_facts = nil
    @metadata = nil
  end

end
