# == Define: libvirt::domain
#
# Define a new libvirt domain. The name of the domain is
# the resource name. The domain_title attribute allows to
# to set a free text title.
#
# === Parameters:
#
# Most parameters are modeled after their equivalents in the libvirt
# domain XML definition. See http://libvirt.org/formatdomain.html
# for more information.
#
# [*max_memory*]
#   Maximum amount of memory that can be allocated to the domain.
# [*initial_memory*]
#   Initial memory allocation for the domain. Defaults to max_memory.
# [*domain_title*]
#   Free text title of the domain. Defaults to ''.
# [*description*]
#   Free text description of the domain. Defaults to ''.
# [*uuid*]
#   UUID for the domain. The default is undef which means
#   that libvirt will generate a UUID for the domain.
# [*cpus*]
#   Number of virtual CPUs for the domain. Defaults to '1'.
# [*boot*]
#   Default boot device. Defaults to 'hd'.
# [*bootmenu*]
#   Wheter the boot menu option should be available or not. Defaults to true.
# [*disks*]
#   Array of hashes defining the disks of this domain. Defaults to no disks
#   at all. The hashes support the following keys:
#     * type:   Disk type, supported types are 'file', 'block', 'network' and
#               'volume'.
#     * device: Disk device type exposed to the guest. Supported values are
#               'floppy', 'disk', 'cdrom' and 'lun'.
#     * source: Hash of source parameters. The supported hash keys vary by the
#               type of disk:
#               file:    'file' key to specify the pathname of the source file
#                        backing this disk.
#               block:   'dev' key to specify the pathname to the block device
#                        backing this disk.
#               network: 'protocol' and 'name'
#               volume:  'pool' and 'volume'
# [*interfaces*]
#   Array of hashes defining the network interfaces of this domain. Defaults to
#   no network interfaces.
#   The hashes support the following keys:
#     * mac:       MAC address of the interface. Without a mac key, a random
#                  address will be assigned by libvirt. The MAC address should
#                  start with 52:54:00.
#     * network:   libvirt network to attach to (mandatory).
#     * portgroup: portgroup to attach to (optional).
#     * type:      Type of network card. Defaults to 'virtio'.
# [*autostart*]
#   Wheter the libvirt autostart flag should be set. Defaults to true. Autostart
#   domains are started if the host is booted.
#
define libvirt::domain (
  $max_memory,
  $initial_memory = $max_memory,
  $domain_title   = '',
  $description    = '',
  $uuid           = undef,
  $cpus           = '1',
  $boot           = 'hd',
  $bootmenu       = true,
  $disks          = [],
  $interfaces     = [],
  $autostart      = true,
) {

  exec {"libvirt-domain-${name}":
    command  => join(['f=$(mktemp) && echo "',
                      template('libvirt/domain.xml.erb'),
                      '" > $f && virsh define $f && rm $f']),
    provider => 'shell',
    creates  => "${params::config_dir}/qemu/${name}.xml",
    require  => Class['libvirt'],
  }

  if ($autostart) {
    exec {"libvirt-domain-autostart-${name}":
      command => "virsh autostart ${name}",
      creates => "${params::config_dir}/qemu/autostart/${name}.xml",
      require => Exec["libvirt-domain-${name}"],
    }

    exec {"libvirt-domain-start-${name}":
      command => "virsh start ${name}",
      unless  => "virsh list --name | grep -q ^${name}$",
      require => Exec["libvirt-domain-${name}"],
    }
  }
}
