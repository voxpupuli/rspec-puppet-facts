require 'facter'
require 'facterdb'
require 'json'

module RspecPuppetFacts

  def on_supported_os( opts = {} )
    opts[:hardwaremodels] ||= ['x86_64']
    opts[:supported_os] ||= RspecPuppetFacts.meta_supported_os

    filter = []
    opts[:supported_os].map do |os_sup|
      if os_sup['operatingsystemrelease']
        os_sup['operatingsystemrelease'].map do |operatingsystemmajrelease|
          opts[:hardwaremodels].each do |hardwaremodel|
            filter << {
              :operatingsystem        => os_sup['operatingsystem'],
              :operatingsystemrelease => "/^#{operatingsystemmajrelease.split(" ")[0]}/",
              :hardwaremodel          => hardwaremodel,
            }
          end
        end
      else
        opts[:hardwaremodels].each do |hardwaremodel|
          filter << {
            :operatingsystem => os_sup['operatingsystem'],
            :hardwaremodel   => hardwaremodel,
          }
        end
      end
    end

    h = {}
    FacterDB::get_os_facts(Facter.version[0..2], filter).map do |facts|
      h["#{facts[:operatingsystem].downcase}-#{facts[:operatingsystemrelease].split('.')[0]}-#{facts[:hardwaremodel]}"] = facts
    end
    h
  end

  # @api private
  def self.meta_supported_os
    @meta_supported_os ||= get_meta_supported_os
  end

  # @api private
  def self.get_meta_supported_os
    metadata = get_metadata
    if metadata['operatingsystem_support'].nil?
      fail StandardError, "Unknown operatingsystem support"
    end
    metadata['operatingsystem_support']
  end

  # @api private
  def self.get_metadata
    if ! File.file?('metadata.json')
      fail StandardError, "Can't find metadata.json... dunno why"
    end
    JSON.parse(File.read('metadata.json'))
  end
end
