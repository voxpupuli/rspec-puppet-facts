module RspecPuppetFacts
  # This module contains lists of all legacy facts
  module LegacyFacts
    # Used to determine if a fact is a legacy fact or not
    #
    # @return [Boolean] Is the fact a legacy fact
    # @param [Symbol] fact Fact name
    def self.legacy_fact?(fact)
      legacy_facts.include?(fact) or fact.to_s.match(Regexp.union(legacy_fact_regexes))
    end

    # @api private
    def self.legacy_fact_regexes
      [
        /\Ablockdevice_(?<devicename>.+)_model\Z/,
        /\Ablockdevice_(?<devicename>.+)_size\Z/,
        /\Ablockdevice_(?<devicename>.+)_vendor\Z/,
        /\Aipaddress6_(?<interface>.+)\Z/,
        /\Aipaddress_(?<interface>.+)\Z/,
        /\Amacaddress_(?<interface>.+)\Z/,
        /\Amtu_(?<interface>.+)\Z/,
        /\Anetmask6_(?<interface>.+)\Z/,
        /\Anetmask_(?<interface>.+)\Z/,
        /\Anetwork6_(?<interface>.+)\Z/,
        /\Anetwork_(?<interface>.+)\Z/,
        /\Ascope6_(?<interface>.+)\Z/,
        /\Aldom_(?<name>.+)\Z/,
        /\Aprocessor\d+\Z/,
        /\Asp_(?<name>.+)\Z/,
        /\Assh(?<algorithm>.+)key\Z/,
        /\Asshfp_(?<algorithm>.+)\Z/,
        /\Azone_(?<name>.+)_brand\Z/,
        /\Azone_(?<name>.+)_id\Z/,
        /\Azone_(?<name>.+)_iptype\Z/,
        /\Azone_(?<name>.+)_name\Z/,
        /\Azone_(?<name>.+)_path\Z/,
        /\Azone_(?<name>.+)_status\Z/,
        /\Azone_(?<name>.+)_uuid\Z/
      ]
    end

    # @api private
    def self.legacy_facts
      %i[
        architecture
        augeasversion
        blockdevices
        bios_release_date
        bios_vendor
        bios_version
        boardassettag
        boardmanufacturer
        boardproductname
        boardserialnumber
        chassisassettag
        chassistype
        dhcp_servers
        domain
        fqdn
        gid
        hardwareisa
        hardwaremodel
        hostname
        id
        interfaces
        ipaddress
        ipaddress6
        lsbdistcodename
        lsbdistdescription
        lsbdistid
        lsbdistrelease
        lsbmajdistrelease
        lsbminordistrelease
        lsbrelease
        macaddress
        macosx_buildversion
        macosx_productname
        macosx_productversion
        macosx_productversion_major
        macosx_productversion_minor
        macosx_productversion_patch
        manufacturer
        memoryfree
        memoryfree_mb
        memorysize
        memorysize_mb
        netmask
        netmask6
        network
        network6
        operatingsystem
        operatingsystemmajrelease
        operatingsystemrelease
        osfamily
        physicalprocessorcount
        processorcount
        productname
        rubyplatform
        rubysitedir
        rubyversion
        scope6
        selinux
        selinux_config_mode
        selinux_config_policy
        selinux_current_mode
        selinux_enforced
        selinux_policyversion
        serialnumber
        swapencrypted
        swapfree
        swapfree_mb
        swapsize
        swapsize_mb
        windows_edition_id
        windows_installation_type
        windows_product_name
        windows_release_id
        system32
        uptime
        uptime_days
        uptime_hours
        uptime_seconds
        uuid
        xendomains
        zonename
        zones
      ]
    end
  end
end
