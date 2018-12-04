# == Define: libvirt::nwfilter
#
# Define a new libvirt nwfilter. The name of the nwfilter is
# the resource name. It expects an ip address and will set up
# firewalling that restricts inbound traffic to the given port
# numbers.
#
# === Parameters:
#
# [*uuid*]
#   The libvirt UUID, optional.
# [*ip*]
#   The VM's IP address, mandatory.
# [*publictcpservices*]
#   An array with portnumbers that should be accessible over
#   TCP from anywhere
# [*publicudpservices*]
#   An array with portnumbers that should be accessible over
#   UDP from anywhere
# [*customtcprules*]
#   An array with rules that allow traffic to a specific TCP
#   port from a specific address. Syntax: 
#   [{remote_ip => port}, ... ]
# [*customudprules*]
#   An array with rules that allow traffic to a specific UDP
#   port from a specific address. Syntax:
#   [{remote_ip => port}, ... ]
#

define libvirt::nwfilter (
  $uuid              = libvirt_generate_uuid($name),
  $ip                = undef,
  $publictcpservices = [],
  $publicudpservices = [],
  $customtcprules    = [],
  $customudprules    = [],
) {

  include ::libvirt

  exec {"libvirt-nwfilter-${name}":
    command  => join(['f=$(mktemp) && echo "',
                      template('libvirt/nwfilter.xml.erb'),
                      '" > $f && virsh nwfilter-define $f && rm $f']),
    provider => 'shell',
    require  => Anchor['libvirt::end'],
  }
}
