# frozen_string_literal: true

module Puppet::Parser::Functions
  newfunction(:libvirt_generate_mac_addresses, type: :rvalue, doc: <<-ENDHEREDOC) do |args|
    Generates MAC addresses for all interfaces in the array which do not yet have an
    address specified. The MAC addresses are based on the domain name, network and
    portgroup or the whole interface configuration (excluding the 'filter' key, to avoid
    mac changes when the firewall rules change).#{' '}
    The function libvirt_generate_mac is used to generate a single mac address.
    Additional remark: If the same network config is attached to a node twice
    the resulting mac address is the same !
    @param
       hash of interfaces
    @return the interfacess with mac address

  ENDHEREDOC

    Puppet::Parser::Functions.function('generate_mac')

    ifaces = args[0]
    domain_name = args[1]

    ifaces.each do |iface|
      next if iface.key?('mac')

      iface['mac'] = if iface['network']
                       function_libvirt_generate_mac([domain_name, iface['network'], iface['portgroup']])
                     elsif iface['source'] && iface['source']['network']
                       function_libvirt_generate_mac([domain_name, iface['source']['network'], iface['source']['portgroup']])
                     else
                       function_libvirt_generate_mac([domain_name, iface.reject { |k, _v| k == 'filter' }.to_s])
                       #  iface.reject{|k, v| k == 'filter'}
                     end
    end
  end
end
