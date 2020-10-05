# libvirt::network
#
# @summary Define a new libvirt network. The name of the network is
#   the resource name.
#
# @note Most parameters are modeled after their equivalents in the libvirt
#   network XML definition. See http://libvirt.org/formatnetwork.html
#   for more information.
#
# @param ensure
# @param bridge
#   Name of the bridge device to use for this network.
# @param forward_mode
#   Network forward mode. Valid modes are 'nat', 'route', 'bridge', 'private',
#   'vepa', 'passthrough' and 'hostdev'. The default is 'bridge'.
# @param virtualport_type
#   Set this to 'openvswitch' for an Open vSwitch bridge. Leave undefined
#   otherwise.
# @param portgroups
#   Array of hashes defining portgroups. This only works for Open vSwitch
#   networks. The hash supports the following keys:
#   * name:     Name of the portgroup.
#   * trunk:    Set to true if this is a trunk port. In this case, the
#               vlan_tag element must contain an array of allowed VLAN
#               tags.
#   * vlan_tag: VLAN tag for this portgroup.
# @param autostart
#   Wheter to start this network on boot or not. Defaults to true.
# @param forward_dev
#    The interface to forward, useful in bridge and route mode
# @param forward_interfaces
#    An array of interfaces to forwad
# @param ip_address
#    The ip address for the device
# @param ip_netmask
#    The netmask for the ip address
# @param dhcp_start
#    Optional dhcp range start
# @param dhcp_end
#    Optional dhcp range end
# @param dns_enable
#    Set this to 'no' to disable the DNS service. Leave undefined otherwise.
# @param mtu
#    Set a custom mtu value. Default is 1500.
#
define libvirt::network (
  String           $ensure             = 'present',
  String           $bridge             = '',
  String           $forward_mode       = 'bridge',
  Optional[String] $forward_dev        = undef,
  Array            $forward_interfaces = [],
  Optional[String] $virtualport_type   = undef,
  Array            $portgroups         = [],
  Boolean          $autostart          = true,
  Optional[String] $ip_address         = undef,
  Optional[String] $ip_netmask         = undef,
  Optional[String] $dhcp_start         = undef,
  Optional[String] $dhcp_end           = undef,
  Optional[String] $dns_enable         = undef,
  Optional[Integer] $mtu               = undef,
) {

  include ::libvirt

  if ($ensure != 'absent') {
    exec {"libvirt-network-${name}":
      command  => join(['f=$(mktemp) && echo "',
                        template('libvirt/network.xml.erb'),
                        '" > $f && virsh net-define $f && rm $f']),
      provider => 'shell',
      creates  => "${libvirt::config_dir}/qemu/networks/${name}.xml",
      require  => Anchor['libvirt::installed'],
    }

    if $libvirt::diff_dir != '' {
      file {"${libvirt::diff_dir}/networks/${name}.xml":
        content => template('libvirt/network.xml.erb'),
      }
    }

    if ($autostart) {
      exec {"libvirt-network-autostart-${name}":
        command  => "virsh net-autostart ${name}",
        provider => 'shell',
        creates  => "${libvirt::config_dir}/qemu/networks/autostart/${name}.xml",
        require  => Exec["libvirt-network-${name}"],
      }

      exec {"libvirt-network-start-${name}":
        command  => "virsh net-start ${name}",
        provider => 'shell',
        unless   => "virsh net-list | tail -n +3 | cut -d ' ' -f 2 | \
                    grep -q ^${name}$",
        require  => Exec["libvirt-network-${name}"],
      }
    }
  } else {
    exec {"libvirt-delete-network-${name}":
      command  => "virsh net-destroy ${name}",
      provider => 'shell',
      onlyif   => "virsh net-list | tail -n +3 | cut -d ' ' -f 2 | \
                    grep -q ^${name}$",
      require  => Anchor['libvirt::installed'],
    }
    exec {"libvirt-network-disable-autostart-${name}":
      command  => "virsh net-autostart ${name} --disable",
      provider => 'shell',
      onlyif   => "test -L /etc/libvirt/qemu/networks/autostart/${name}.xml",
      require  => Exec["libvirt-delete-network-${name}"],
    }
    exec {"libvirt-undefine-network-${name}":
      command  => "virsh net-undefine ${name}",
      provider => 'shell',
      onlyif   => "test -f /etc/libvirt/qemu/networks/${name}.xml",
      require  => Exec["libvirt-network-disable-autostart-${name}"],
    }
  }
}
