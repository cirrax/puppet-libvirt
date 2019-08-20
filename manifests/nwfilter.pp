# libvirt::nwfilter
#
# Define a new libvirt nwfilter. The name of the nwfilter is
# the resource name. It expects an ip address and will set up
# firewalling that restricts inbound traffic to the given port
# numbers.
#
# @param uuid
#   The libvirt UUID, optional.
# @param ip
#   The VM's IP address, mandatory.
# @param publictcpservices
#   An array with portnumbers that should be accessible over
#   TCP from anywhere
# @param publicudpservices
#   An array with portnumbers that should be accessible over
#   UDP from anywhere
# @param customtcprules
#   An array with rules that allow traffic to a specific TCP
#   port from a specific address. Syntax: 
#   `[{remote_ip => port}, ... ]`
# @param customudprules
#   An array with rules that allow traffic to a specific UDP
#   port from a specific address. Syntax:
#   `[{remote_ip => port}, ... ]`
#
define libvirt::nwfilter (
  String           $uuid              = libvirt_generate_uuid($name),
  Optional[String] $ip                = undef,
  Array            $publictcpservices = [],
  Array            $publicudpservices = [],
  Array            $customtcprules    = [],
  Array            $customudprules    = [],
) {

  include ::libvirt

  exec {"libvirt-nwfilter-${name}":
    command  => join(['f=$(mktemp) && echo "',
                      template('libvirt/nwfilter.xml.erb'),
                      '" > $f && virsh nwfilter-define $f && rm $f']),
    provider => 'shell',
    require  => Anchor['libvirt::end'],
  }

  if $libvirt::diff_dir != '' {
    file {"${libvirt::diff_dir}/nwfilters/${name}.xml":
      content => template('libvirt/nwfilter.xml.erb'),
    }
  }
}
