require 'puppet'
require 'facter'
require 'facterdb'
require 'json'
require 'mcollective'

module RspecPuppetFacts

  def on_supported_os( opts = {} )
    opts = RspecPuppetFacts.deep_symbolize(opts)
    opts[:hardwaremodels] ||= ['x86_64']
    opts[:supported_os] ||= RspecPuppetFacts.meta_supported_os

    filter = []
    opts[:supported_os].map do |os_sup|
      if os_sup[:operatingsystemrelease]
        os_sup[:operatingsystemrelease].map do |operatingsystemmajrelease|
          opts[:hardwaremodels].each do |hardwaremodel|

            if os_sup[:operatingsystem] =~ /BSD/
              hardwaremodel = 'amd64'
            elsif os_sup[:operatingsystem] =~ /Solaris/
              hardwaremodel = 'i86pc'
            elsif os_sup[:operatingsystem] =~ /windows/
              hardwaremodel = 'x64'
            end

            filter << {
              :facterversion          => "/^#{Facter.version[0..2]}/",
              :operatingsystem        => os_sup[:operatingsystem],
              :operatingsystemrelease => "/^#{operatingsystemmajrelease.split(" ")[0]}/",
              :hardwaremodel          => hardwaremodel,
            }
          end
        end
      else
        opts[:hardwaremodels].each do |hardwaremodel|
          filter << {
            :facterversion   => "/^#{Facter.version[0..2]}/",
            :operatingsystem => os_sup[:operatingsystem],
            :hardwaremodel   => hardwaremodel,
          }
        end
      end
    end

    h = {}
    FacterDB::get_facts(filter).map do |facts|
      facts.merge!({
        :mco_version   => MCollective::VERSION,
        :puppetversion => Puppet.version,
        :rubysitedir   => RbConfig::CONFIG["sitelibdir"],
        :rubyversion   => RUBY_VERSION,
      })
      facts[:augeasversion] = Augeas.open(nil, nil, Augeas::NO_MODL_AUTOLOAD).get('/augeas/version') if Puppet.features.augeas?
      h["#{facts[:operatingsystem].downcase}-#{facts[:operatingsystemrelease].split('.')[0]}-#{facts[:hardwaremodel]}"] = facts
    end
    h
  end

  # @api private
  def self.deep_symbolize(obj)
    return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  deep_symbolize(v); memo} if obj.is_a? Hash
    return obj.inject([]){|memo,v    | memo           << deep_symbolize(v); memo} if obj.is_a? Array
    return obj
  end

  # @api private
  def self.meta_supported_os
    @meta_supported_os ||= get_meta_supported_os
  end

  # @api private
  def self.get_meta_supported_os
    metadata = get_metadata
    if metadata[:operatingsystem_support].nil?
      fail StandardError, "Unknown operatingsystem support"
    end
    metadata[:operatingsystem_support]
  end

  # @api private
  def self.get_metadata
    if ! File.file?('metadata.json')
      fail StandardError, "Can't find metadata.json... dunno why"
    end
    JSON.parse(File.read('metadata.json'), {:symbolize_names => true})
  end
end
