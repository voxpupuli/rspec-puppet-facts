require 'puppet'
require 'facter'
require 'facterdb'
require 'json'
require 'mcollective'
require 'yaml'

# The purpose of this module is to simplify the Puppet
# module's RSpec tests by looping through all supported
# OS'es and their facts data which is received from the FacterDB.
module RspecPuppetFacts
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

    filter = []
    opts[:supported_os].map do |os_sup|
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

    received_facts = FacterDB::get_facts(filter)
    unless received_facts.any?
      RspecPuppetFacts.warning "No facts were found in the FacterDB for: #{filter.inspect}"
      return {}
    end

    os_facts_hash = {}
    received_facts.map do |facts|
      # Fix facter bug
      if facts[:operatingsystem] == 'Ubuntu'
        operatingsystemmajrelease = facts[:operatingsystemrelease].split('.')[0..1].join('.')
      elsif facts[:operatingsystem] == 'OpenBSD'
        operatingsystemmajrelease = facts[:operatingsystemrelease]
      else
        if facts[:operatingsystemmajrelease].nil?
          operatingsystemmajrelease = facts[:operatingsystemrelease].split('.')[0]
        else
          operatingsystemmajrelease = facts[:operatingsystemmajrelease]
        end
      end
      os = "#{facts[:operatingsystem].downcase}-#{operatingsystemmajrelease}-#{facts[:hardwaremodel]}"
      next unless os.start_with? RspecPuppetFacts.spec_facts_os_filter if RspecPuppetFacts.spec_facts_os_filter
      facts.merge! RspecPuppetFacts.common_facts
      os_facts_hash[os] = RspecPuppetFacts.with_custom_facts(os, facts)
    end
    os_facts_hash
  end

  # Register a custom fact that will be included in the facts hash.
  # If it should be limited to a particular OS, pass a :confine option
  # that contains the operating system(s) to confine to.  If it should
  # be excluded on a particular OS, use :exclude.
  #
  # @param [String]      name           Fact name
  # @param [String,Proc] value          Fact value. If proc, takes 2 params: os and facts hash
  # @param [Hash]        opts
  # @option opts [String,Array<String>] :confine The applicable OS's
  # @option opts [String,Array<String>] :exclude OS's to exclude
  #
  def add_custom_fact(name, value, options = {})
    options[:confine] = [options[:confine]] if options[:confine].is_a?(String)
    options[:exclude] = [options[:exclude]] if options[:exclude].is_a?(String)

    RspecPuppetFacts.register_custom_fact(name, value, options)
  end

  # Register all custom facts from yaml for inclusion in the facts hash.
  #
  # @param [String]      file           Path to YAML File in base <module>/spec dir
  # @option opts [String,Array<String>] :confine The applicable OS's
  # @option opts [String,Array<String>] :exclude OS's to exclude
  #
  def add_custom_facts_from_yaml(file, options = {})
    options[:confine] = [options[:confine]] if options[:confine].is_a?(String)
    options[:exclude] = [options[:exclude]] if options[:exclude].is_a?(String)

    # Ensure YAML File Exists - error if not found
    fail StandardError, "YAML file: #{file} not found - facts cannot be loaded!" unless File.exists?(file)
    # Ensure Loading YAML File does not yield empty var - error if empty
    fail StandardError, "YAML Variables Not Loaded - YAML file: #{file} is empty" unless !File.zero?(file)
    yaml_facts = YAML.load_file(file)
    fail StandardError, "YAML Variables Not Loaded - is YAML file: #{file} empty?" unless !yaml_facts.nil?

    # Iterate through yaml variables, and invoke custom fact registration
    yaml_facts.each_pair do |key, value|
      RspecPuppetFacts.register_custom_fact(key, value, options)
    end
  end

  # Adds a custom fact to the @custom_facts variable.
  #
  # @param [String]      name           Fact name
  # @param [String,Proc] value          Fact value. If proc, takes 2 params: os and facts hash
  # @param [Hash]        opts
  # @option opts [String,Array<String>] :confine The applicable OS's
  # @option opts [String,Array<String>] :exclude OS's to exclude
  # @api private
  def self.register_custom_fact(name, value, options)
    @custom_facts ||= {}
    @custom_facts[name.to_s] = {:options => options, :value => value}
  end

  # Adds any custom facts according to the rules defined for the operating
  # system with the given facts.
  # @param [String] os    Name of the operating system
  # @param [Hash]   facts Facts hash
  # @return [Hash]  facts Facts hash with custom facts added
  # @api private
  def self.with_custom_facts(os, facts)
    return facts unless @custom_facts

    @custom_facts.each do |name, fact|
      next if fact[:options][:confine] && !fact[:options][:confine].include?(os)
      next if fact[:options][:exclude] && fact[:options][:exclude].include?(os)

      facts[name] = fact[:value].respond_to?(:call) ? fact[:value].call(os, facts) : fact[:value]
    end

    facts
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
    @custom_facts = nil
    @common_facts = nil
    @metadata = nil
  end

end
