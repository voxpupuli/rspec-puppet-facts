require 'puppet'
require 'facter'
require 'facterdb'
require 'json'
require 'mcollective'

module RspecPuppetFacts

  def on_supported_os( opts = {} )
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
      os = "#{facts[:operatingsystem].downcase}-#{facts[:operatingsystemrelease].split('.')[0]}-#{facts[:hardwaremodel]}"
      facts.merge! RspecPuppetFacts.common_facts
      os_facts_hash[os] = facts
    end
    os_facts_hash
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

  # @api private
  def self.meta_supported_os
    unless metadata['operatingsystem_support'].is_a? Array
      fail StandardError, 'Unknown operatingsystem support in the metadata file!'
    end
    metadata['operatingsystem_support']
  end

  # @api private
  def self.metadata
    return @metadata if @metadata
    unless File.file? metadata_file
      fail StandardError, "Can't find metadata.json... dunno why"
    end
    content = File.read metadata_file
    @metadata = JSON.parse content
  end

  # @api private
  def self.metadata_file
    'metadata.json'
  end

  # @api private
  def self.warning(message)
    STDERR.puts message
  end

  # @api private
  def self.reset
    @common_facts = nil
    @metadata = nil
  end
end
