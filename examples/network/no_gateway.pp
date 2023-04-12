# 
# A valid network definition can contain no IPv4 or IPv6 addresses.
# Such a definition can be used for a "very private" or "very isolated"
# network since it will not be possible to communicate with the
# virtualization host via this network. However, this virtual 
# network interface can be used for communication between virtual
# guest systems. This works for IPv4 and (Since 1.0.1) IPv6.
# However, the new ipv6='yes' must be added for guest-to-guest IPv6 communication.
#
# The resulting XML definition is:
#
#<network ipv6='yes'>
# <name>nogw</name>
# <bridge name="virbr2" stp="on" delay="0"/>
# <mac address='00:16:3E:5D:C7:9E'/>
#</network>
#
# as puppet code:

libvirt::network { 'nogw':
  bridge => { 'name' => 'virbr2', 'stp' => 'on', 'delay' => 0 },
  mac    => { 'address' => '00:16:3E:5D:C7:9E' },
}

# or in hiera yaml:
#
# libvirt::create_networks:
#   nogw:
#     bridge:
#       name: 'virbr2'
#       stp: 'on'
#       delay: 0
#     mac:
#       address: '00:16:3E:5D:C7:9E'
#
#
# Reference: These examples (description and resulting XML) are from the
# libvirt documentation at: https://libvirt.org/formatnetwork.html
