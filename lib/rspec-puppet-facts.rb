require 'puppet'
require 'facter'
require 'facterdb'
require 'json'
require 'deep_merge'

# The purpose of this module is to simplify the Puppet
# module's RSpec tests by looping through all supported
# OS'es and their facts data which is received from the FacterDB.
module RspecPuppetFacts
  FACTS_CACHE = {}

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
  # @option opts [String] :facterversion the facter version of which to
  # select facts from, e.g.: '3.6'
  # will be used instead of the "operatingsystem_support" section if the metadata file
  # even if the file is missing.
  def on_supported_os(opts = {})
    opts[:hardwaremodels] ||= ['x86_64']
    opts[:hardwaremodels] = [opts[:hardwaremodels]] unless opts[:hardwaremodels].is_a? Array
    opts[:supported_os] ||= RspecPuppetFacts.meta_supported_os
    opts[:facterversion] ||= RSpec.configuration.default_facter_version

    # This should list all variables that on_supported_os_implementation uses
    cache_key = [
      opts.to_s,
      RspecPuppetFacts.custom_facts.to_s,
      RspecPuppetFacts.spec_facts_os_filter,
      RspecPuppetFacts.spec_facts_strict?,
    ]

    result = FACTS_CACHE[cache_key] ||= on_supported_os_implementation(opts)

    # Marshalling is used to get unique instances which is needed for test
    # isolation when facts are overridden.
    Marshal.load(Marshal.dump(result))
  end

  # The real implementation of on_supported_os.
  #
  # Generating facts is slow - this allows memoization of the facts between
  # multiple calls.
  #
  # @api private
  def on_supported_os_implementation(opts = {})
    unless /\A\d+\.\d+(?:\.\d+)*\z/.match?((facterversion = opts[:facterversion]))
      raise ArgumentError, ":facterversion must be in the format 'n.n' or 'n.n.n' (n is numeric), not '#{facterversion}'"
    end

    filter = []
    opts[:supported_os].map do |os_sup|
      if os_sup['operatingsystemrelease']
        Array(os_sup['operatingsystemrelease']).map do |operatingsystemmajrelease|
          opts[:hardwaremodels].each do |hardwaremodel|
            os_release_filter = "/^#{Regexp.escape(operatingsystemmajrelease.split(' ')[0])}/"
            case os_sup['operatingsystem']
            when /BSD/i
              hardwaremodel = 'amd64'
            when /Solaris/i
              hardwaremodel = 'i86pc'
            when /AIX/i
              hardwaremodel = '/^IBM,.*/'
              os_release_filter = if operatingsystemmajrelease =~ /\A(\d+)\.(\d+)\Z/
                                    "/^#{$~[1]}#{$~[2]}00-/"
                                  else
                                    "/^#{operatingsystemmajrelease}-/"
                                  end
            when /Windows/i
              hardwaremodel = 'x86_64'
              os_sup['operatingsystem'] = os_sup['operatingsystem'].downcase
              operatingsystemmajrelease = operatingsystemmajrelease[/\A(?:Server )?(.+)/i, 1]

              # force quoting because windows releases can contain spaces
              os_release_filter = "\"#{operatingsystemmajrelease}\""
            when /Amazon/i
              # Tighten the regex for Amazon Linux 2 so that we don't pick up Amazon Linux 2016 or 2017 facts
              os_release_filter = '/^2$/' if operatingsystemmajrelease == '2'
            end

            filter << {
              'os.name' => os_sup['operatingsystem'],
              'os.release.full' => os_release_filter,
              'os.hardware' => hardwaremodel,
            }
          end
        end
      else
        opts[:hardwaremodels].each do |hardwaremodel|
          filter << {
            'os.name' => os_sup['operatingsystem'],
            'os.hardware' => hardwaremodel,
          }
        end
      end
    end

    strict_requirement = RspecPuppetFacts.facter_version_to_strict_requirement(facterversion)

    loose_requirement = RspecPuppetFacts.facter_version_to_loose_requirement(facterversion)
    received_facts = []

    # FacterDB may have newer versions of facter data for which it contains a subset of all possible
    # facter data (see FacterDB 0.5.2 for Facter releases 3.8 and 3.9). In this situation we need to
    # cycle through and downgrade Facter versions per platform type until we find matching Facter data.
    facterversion_key = RSpec.configuration.facterdb_string_keys ? 'facterversion' : :facterversion
    filter.each do |filter_spec|
      versions = FacterDB.get_facts(filter_spec, symbolize_keys: !RSpec.configuration.facterdb_string_keys).to_h do |facts|
        [Gem::Version.new(facts[facterversion_key]), facts]
      end

      version, facts = versions.select { |v, _f| strict_requirement =~ v }.max_by { |v, _f| v }

      unless version
        version, facts = versions.select { |v, _f| loose_requirement =~ v }.max_by { |v, _f| v } if loose_requirement
        next unless version

        raise ArgumentError, "No facts were found in the FacterDB for Facter v#{facterversion} on #{filter_spec}, aborting" if RspecPuppetFacts.spec_facts_strict?

        RspecPuppetFacts.warning "No facts were found in the FacterDB for Facter v#{facterversion} on #{filter_spec}, using v#{version} instead"
      end

      received_facts << facts
    end

    unless received_facts.any?
      RspecPuppetFacts.warning "No facts were found in the FacterDB for: #{filter.inspect}"
      return {}
    end

    os_facts_hash = {}
    received_facts.map do |facts|
      os_fact = RSpec.configuration.facterdb_string_keys ? facts['os'] : facts[:os]
      unless os_fact
        RspecPuppetFacts.warning "No os fact was found in FacterDB for: #{facts}"
        next
      end

      os = "#{os_fact['name'].downcase}-#{os_fact['release']['major']}-#{os_fact['hardware']}"
      next if RspecPuppetFacts.spec_facts_os_filter && !os.start_with?(RspecPuppetFacts.spec_facts_os_filter)

      facts.merge! RspecPuppetFacts.common_facts
      os_facts_hash[os] = RspecPuppetFacts.with_custom_facts(os, facts)
    end

    os_facts_hash
  end

  # @api private
  def stringify_keys(hash)
    hash.to_h { |k, v| [k.to_s, v.is_a?(Hash) ? stringify_keys(v) : v] }
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
    name = RSpec.configuration.facterdb_string_keys ? name.to_s : name.to_sym
    @custom_facts[name] = { options: options, value: value }
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

      value = fact[:value].respond_to?(:call) ? fact[:value].call(os, facts) : fact[:value]
      # if merge_facts passed, merge supplied facts into facts hash
      if fact[:options][:merge_facts]
        facts.deep_merge!({ name => value })
      else
        facts[name] = value
      end
    end

    facts
  end

  # Get custom facts
  # @return [nil,Hash]
  # @api private
  def self.custom_facts
    @custom_facts
  end

  # If provided this filter can be used to limit the set
  # of retrieved facts only to the matched OS names.
  # The value is being taken from the SPEC_FACTS_OS environment
  # variable and
  # @return [nil,String]
  # @api private
  def self.spec_facts_os_filter
    ENV.fetch('SPEC_FACTS_OS', nil)
  end

  # If SPEC_FACTS_STRICT is set to `yes`, RspecPuppetFacts will error on missing FacterDB entries, instead of warning & skipping the tests, or using an older facter version.
  # @return [Boolean]
  # @api private
  def self.spec_facts_strict?
    ENV['SPEC_FACTS_STRICT'] == 'yes'
  end

  # These facts are common for all OS'es and will be
  # added to the facts retrieved from the FacterDB
  # @api private
  # @return [Hash <Symbol => String>]
  def self.common_facts
    return @common_facts if @common_facts

    @common_facts = {
      puppetversion: Puppet.version,
      rubysitedir: RbConfig::CONFIG['sitelibdir'],
      rubyversion: RUBY_VERSION,
    }

    @common_facts[:mco_version] = MCollective::VERSION if mcollective?

    if augeas?
      @common_facts[:augeasversion] = Augeas.open(nil, nil, Augeas::NO_MODL_AUTOLOAD).get('/augeas/version')
    end
    @common_facts = stringify_keys(@common_facts) if RSpec.configuration.facterdb_string_keys

    @common_facts
  end

  # Determine if the Augeas gem is available.
  # @api private
  # @return [Boolean] true if the augeas gem could be loaded.
  # :nocov:
  def self.augeas?
    require 'augeas'
    true
  rescue LoadError
    false
  end
  # :nocov:

  # Determine if the mcollective gem is available
  # @api private
  # @return [Boolean] true if the mcollective gem could be loaded.
  # :nocov:
  def self.mcollective?
    require 'mcollective'
    true
  rescue LoadError
    false
  end
  # :nocov:

  # Get the "operatingsystem_support" structure from
  # the parsed metadata.json file
  # @raise [StandardError] if there is no "operatingsystem_support"
  # in the metadata
  # @return [Array<Hash>]
  # @api private
  def self.meta_supported_os
    unless metadata['operatingsystem_support'].is_a? Array
      raise StandardError, 'Unknown operatingsystem support in the metadata file!'
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
      raise StandardError, "Can't find metadata.json... dunno why"
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
    warn message
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

  # Construct the strict facter version requirement
  # @return [Gem::Requirement] The version requirement to match
  # @api private
  def self.facter_version_to_strict_requirement(version)
    Gem::Requirement.new(facter_version_to_strict_requirement_string(version))
  end

  # Construct the strict facter version requirement string
  # @return [String] The version requirement to match
  # @api private
  def self.facter_version_to_strict_requirement_string(version)
    if /\A[0-9]+(\.[0-9]+)*\Z/.match?(version)
      # Interpret 3 as ~> 3.0
      "~> #{version}.0"
    else
      version
    end
  end

  # Construct the loose facter version requirement
  # @return [Optional[Gem::Requirement]] The version requirement to match
  # @api private
  def self.facter_version_to_loose_requirement(version)
    string = facter_version_to_loose_requirement_string(version)
    Gem::Requirement.new(string) if string
  end

  # Construct the facter version requirement string
  # @return [String] The version requirement to match
  # @api private
  def self.facter_version_to_loose_requirement_string(version)
    if (m = /\A(?<major>[0-9]+)\.(?<minor>[0-9]+)(?:\.(?<patch>[0-9]+))?\Z/.match(version))
      # Interpret 3.1 as < 3.2 and 3.2.1 as < 3.3
      "< #{m[:major]}.#{m[:minor].to_i + 1}"
    elsif /\A[0-9]+\Z/.match?(version)
      # Interpret 3 as < 4
      "< #{version.to_i + 1}"
    else # rubocop:disable Style/EmptyElse
      # This would be the same as the strict requirement
      nil
    end
  end

  def self.facter_version_for_puppet_version(puppet_version)
    return Facter.version if puppet_version.nil?

    json_path = File.expand_path(File.join(__dir__, '..', 'ext', 'puppet_agent_components.json'))
    unless File.file?(json_path) && File.readable?(json_path)
      warning "#{json_path} does not exist or is not readable, defaulting to Facter #{Facter.version}"
      return Facter.version
    end

    fd = File.open(json_path, 'rb:UTF-8')
    data = JSON.parse(fd.read)

    version_map = data.map do |_, versions|
      if versions['puppet'].nil? || versions['facter'].nil?
        nil
      else
        [Gem::Version.new(versions['puppet']), versions['facter']]
      end
    end.compact

    puppet_gem_version = Gem::Version.new(puppet_version)
    applicable_versions = version_map.select { |p, _| puppet_gem_version >= p }
    if applicable_versions.empty?
      warning "Unable to find Puppet #{puppet_version} in #{json_path}, defaulting to Facter #{Facter.version}"
      return Facter.version
    end

    applicable_versions.max_by { |p, _| p }.last
  rescue JSON::ParserError
    warning "#{json_path} contains invalid JSON, defaulting to Facter #{Facter.version}"
    Facter.version
  ensure
    fd.close if fd
  end
end

RSpec.configure do |c|
  c.add_setting :default_facter_version, default: RspecPuppetFacts.facter_version_for_puppet_version(Puppet.version)
  c.add_setting :facterdb_string_keys, default: false
end
