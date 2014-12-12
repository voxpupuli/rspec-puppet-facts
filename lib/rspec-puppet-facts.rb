require 'facter'
require 'json'

module RspecPuppetFacts

  def on_supported_os(supported_os = RspecPuppetFacts.meta_supported_os)
    h = {}
    supported_os.map do |os_sup|
      facts = {}
      # TODO: use SemVer here
      facter_minor_version = Facter.version[0..2]
      file = File.expand_path(File.join(File.dirname(__FILE__), "../facts/#{facter_minor_version}/#{os_sup}.facts"))
      File.read(file).each_line do |line|
        key, value = line.split(' => ')
        facts[key.to_sym] = value.chomp unless value.nil?
      end
      h[os_sup] = facts
    end
    h
  end

  # @api private
  def self.meta_supported_os
    @meta_supported_os ||= get_meta_supported_os
  end

  # @api private
  def self.meta_to_facts(input)
    meta_to_facts = {
      'RedHat'      => 'redhat',
      'CentOS'      => 'centos',
      'Ubuntu'      => 'ubuntu',
      'OracleLinux' => 'oracle',
      'SLES'        => 'sles',
      'Scientific'  => 'scientific',
      'Debian'      => 'debian',
      'Fedora'      => 'fedora',
    }
    ans = meta_to_facts[input]
    if ans
      ans
    else
      input
    end
  end

  # @api private
  def self.get_meta_supported_os
    metadata = get_metadata
    if metadata['operatingsystem_support'].nil?
      fail StandardError, "Unknown operatingsystem support"
    end
    os_sup = metadata['operatingsystem_support']

    os_sup.collect do |os_rel|
      os = meta_to_facts(os_rel['operatingsystem'])
      os_rel['operatingsystemrelease'].collect do |release|
        rel = meta_to_facts(release)
        [
          "#{os}-#{rel}-i386",
          "#{os}-#{rel}-x86_64"
        ]
      end
    end.flatten
  end

  # @api private
  def self.get_metadata
    if ! File.file?('metadata.json')
      fail StandardError, "Can't find metadata.json... dunno why"
    end
    metadata = JSON.parse(File.read('metadata.json'))
    if metadata.nil?
      fail StandardError, "Metadata is empty"
    end
    metadata
  end
end
