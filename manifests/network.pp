# == Define: libvirt::network
#
# Define a new libvirt network. The name of the network is
# the resource name.
#
# === Parameters:
#
# Most parameters are modeled after their equivalents in the libvirt
# network XML definition. See http://libvirt.org/formatnetwork.html
# for more information.
#
# [*bridge*]
#   Name of the bridge device to use for this network.
# [*forward_mode*]
#   Network forward mode. Valid modes are 'nat', 'route', 'bridge', 'private',
#   'vepa', 'passthrough' and 'hostdev'. The default is 'bridge'.
# [*virtualport_type*]
#   Set this to 'openvswitch' for an Open vSwitch bridge. Leave undefined
#   otherwise.
# [*portgroups*]
#   Array of hashes defining portgroups. This only works for Open vSwitch
#   networks. The hash supports the following keys:
#   * name:     Name of the portgroup.
#   * trunk:    Set to true if this is a trunk port. In this case, the
#               vlan_tag element must contain an array of allowed VLAN
#               tags.
#   * vlan_tag: VLAN tag for this portgroup.
# [*autostart*]
#   Wheter to start this network on boot or not. Defaults to true.
# [*forward_dev*]
#    The interface to forward, useful in bridge and route mode
# [*forward_interfaces*]
#    An array of interfaces to forwad
# [*ip_address*]
#    The ip address for the device
# [*ip_netmask*]
#    The netmask for the ip address
#
define libvirt::network (
  $ensure             = 'present',
  $bridge             = '',
  $forward_mode       = 'bridge',
  $forward_dev        = undef,
  $forward_interfaces = [],
  $virtualport_type   = undef,
  $portgroups         = [],
  $autostart          = true,
  $ip_address         = undef,
  $ip_netmask         = undef,
  $dhcp_start         = undef,
  $dhcp_end           = undef,
) {

  include ::libvirt

  if ($ensure != 'absent') {
    exec {"libvirt-network-${name}":
      command  => join(['f=$(mktemp) && echo "',
                        template('libvirt/network.xml.erb'),
                        '" > $f && virsh net-define $f && rm $f']),
      provider => 'shell',
      creates  => "${libvirt::params::config_dir}/qemu/networks/${name}.xml",
      require  => Anchor['libvirt::installed'],
    }

    if ($autostart) {
      exec {"libvirt-network-autostart-${name}":
        command  => "virsh net-autostart ${name}",
        provider => 'shell',
        creates  => "${libvirt::params::config_dir}/qemu/networks/autostart/${name}.xml",
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
