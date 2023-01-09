module Puppet::Parser::Functions
  newfunction(:libvirt_generate_mac_addresses, type: :rvalue, doc: <<-'ENDHEREDOC') do |args|
    Generates MAC addresses for all interfaces in the array which do not yet have an
    address specified. The MAC addresses are based on the domain name, network and
    portgroup. The function libvirt_generate_mac is used to generate a single mac address.
    @param
       hash of interfaces
    @return the interfacess with mac address

    ENDHEREDOC

    Puppet::Parser::Functions.function('generate_mac')

    ifaces = args[0]
    domain_name = args[1]

    ifaces.each do |iface|
      unless iface.key?('mac')
        iface['mac'] = function_libvirt_generate_mac([domain_name, iface['network'], iface['portgroup']])
      end
    end
  end
end
