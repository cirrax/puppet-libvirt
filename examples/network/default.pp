# 
# This example is the so called "default" virtual network.
# It is provided and enabled out-of-the-box for all libvirt 
# installations. This is a configuration that allows guest OS
# to get outbound connectivity regardless of whether the host
# uses ethernet, wireless, dialup, or VPN networking without
# requiring any specific admin configuration. In the absence
# of host networking, it at least allows guests to talk directly to each other.
#
# The resulting XML definition is:
# 
# <network>
#  <name>default</name>
#  <bridge name="virbr0"/>
#  <forward mode="nat"/>
#  <ip address="192.168.122.1" netmask="255.255.255.0">
#    <dhcp>
#      <range start="192.168.122.2" end="192.168.122.254"/>
#    </dhcp>
#  </ip>
#  <ip family="ipv6" address="2001:db8:ca2:2::1" prefix="64"/>
# </network>
#

libvirt::network { 'default':
  bridge  => 'virbr2',
  forward => { 'mode' => 'nat' },
  ips     => [
    {
      'address' => '192.168.122.1',
      'netmask' => '255.255.255.0',
      'dhcp'    => {
        'range' => [{ 'start' => '192.168.122.2', 'end' => '192.168.122.254' }],
      },
    }, {
      'family'  => 'ipv6',
      'address' => '2001:db8:ca2:2::1',
      'prefix'  => '64',
    }
  ],
}

# or in hiera yaml:
#
# libvirt::create_networks:
#   default:
#     bridge:
#       name: 'virbr2'
#     forward:
#       mode: 'nat'
#     ips:
#       - address: '192.168.122.1'
#         netmask: '255.255.255.0'
#         dhcp:
#           - range:
#               start: '192.168.122.2'
#               end: '192.168.122.254'
#       - family: 'ipv6'
#         address: '2001:db8:ca2:2::1'
#         prefix: '64'
#
# Below is a variation of the above example which adds an IPv6 dhcp range definition.
#
# The resulting XML defintion is:
# 
# <network>
#   <name>default6</name>
#   <bridge name="virbr0"/>
#   <forward mode="nat"/>
#   <ip address="192.168.122.1" netmask="255.255.255.0">
#     <dhcp>
#       <range start="192.168.122.2" end="192.168.122.254"/>
#     </dhcp>
#   </ip>
#   <ip family="ipv6" address="2001:db8:ca2:2::1" prefix="64">
#     <dhcp>
#       <range start="2001:db8:ca2:2:1::10" end="2001:db8:ca2:2:1::ff"/>
#     </dhcp>
#   </ip>
# </network>
#
# in hiera yaml we would use:
#
# libvirt::create_networks:
#   default6:
#     bridge:
#       name: 'virbr0'
#     forward:
#       mode: 'nat'
#     ips:
#       - address: '192.168.122.1'
#         netmask: '255.255.255.0'
#         dhcp:
#           - range:
#               start: '192.168.122.2'
#               end: '192.168.122.254'
#       - family: 'ipv6'
#         address: '2001:db8:ca2:2::1'
#         prefix: '64'
#         dhcp:
#           - range:
#               start: '2001:db8:ca2:2:1::10'
#               end: '2001:db8:ca2:2:1::ff'
#
#
# Reference: These examples (description and resulting XML) are from the
# libvirt documentation at: https://libvirt.org/formatnetwork.html
