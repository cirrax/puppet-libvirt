#
# libvirt::domain
#
# @summary Define a new libvirt domain. The name of the domain is
#   the resource name. The domain_title attribute allows to
#   to set a free text title.
#
# @note Most parameters are modeled after their equivalents in the libvirt
#   domain XML definition. See http://libvirt.org/formatdomain.html
#   for more information.
#
# @param type
#   Specify the hypervisor used for running the domain.
#   The allowed values are driver specific, but include "xen", "kvm", "qemu" and "lxc"
#   Defaults to 'kvm'
# @param domain_title
#   Free text title of the domain. Defaults to ''.
# @param description
#   Free text description of the domain. Defaults to ''.
# @param uuid
#   UUID for the domain. The default is the uuid, generated
#   with puppet.
# @param boot
#   Default boot device. Valid values are any accepted by libvirt or the string
#   'per-device' to set individual boot orders on disks or interfaces.
#   Defaults to 'hd'.
# @param disks
#   Array of hashes defining the disks of this domain. Defaults to no disks
#   at all. The hashes support the following keys:
#     * type:       Disk type, supported types are 'file', 'block', 'network' and
#                   'volume'.
#     * device:     Disk device type exposed to the guest. Supported values are
#                   'floppy', 'disk', 'cdrom' and 'lun'.
#     * bus:        Target bus, defaults to 'virtio'.
#     * source:     Hash of source parameters. The supported hash keys vary by the
#                   type of disk:
#                   file:    'file' key to specify the pathname of the source file
#                            backing this disk.
#                   block:   'dev' key to specify the pathname to the block device
#                            backing this disk.
#                   network: 'protocol' and 'name'
#                   volume:  'pool' and 'volume'
#    * driver:      Hash of driver parameters. Defaults to raw disks images, no caching
#                   and native io. Use {'name' => 'qemu', 'type' => 'qcow2'} for QCOW2
#                   images.
#                   See the libvirt domain XML documentation for all possible values.
#    * boot_order:  Integer starting at 1 for the highest priority (shared with
#                   interfaces).
# @param interfaces
#   Array of hashes defining the network interfaces of this domain. Defaults to
#   no network interfaces.
#   The hashes support the following keys:
#     * mac:        MAC address of the interface. Without a mac key, a random
#                   address will be assigned by libvirt. The MAC address should
#                   start with 52:54:00.
#     * network:    libvirt network to attach to (mandatory).
#     * portgroup:  portgroup to attach to (optional).
#     * type:       Type of network card. Defaults to 'virtio'.
#     * boot_order: Integer starting at 1 for the highest priority (shared with
#                   disks).
# @param autostart
#   Wheter the libvirt autostart flag should be set. Defaults to true. Autostart
#   domains are started if the host is booted.
# @param dom_profile
#   profile to use for $domconf.
#   Defaults to 'default' which is defined in data/profiles/xxx.yaml
#   A profile is a predefined set of parameters for a vm.
#   see class libvirt::profiles for additional information.
# @param domconf
#   the generic domain configuration to activate for vm.
#   this parameter is merged with the choosen profile,
#   ($libvirt::profiles::domconf)
#   to generate the final configuration.
#   Defaults to {} which does not change the profile.
#   see also libvirt::profiles for how to use profiles
# @param devices_profile
#   profile to use for $devices.
#   Defaults to 'default' which is defined in data/profiles/xxx.yaml
#   A profile is a predefined set of parameters for a vm.
#   see class libvirt::profiles for additional information.
# @param devices
#   devices to attach to the vm
#   this parameter is merged with the choosen profile,
#   ($libvirt::profiles::devices)
#   to generate the final configuration.
#   Defaults to {} which does not change the profile.
#   see also libvirt::profiles for how to use profiles
# @param additionaldevices
#   additional devices to attach to the vm
#   Same format as $devices, but without merging.
#   Defaults to {}
#
# @param default_host
#   FQDN for the default host of this domain. The manage-domains script uses
#   this value to move a domain to it's default host if it's running elsewhere.
#   <p>Only useful together with the drbd qemu_hook in setups of two
#   redundant virtualization hosts synchronized over DRBD. They
#   have no effect if qemu_hook is not set to drbd.
# @param evacuation
#   Evacuation policy for this domain. Valid values are 'migrate', 'save' and
#   'shutdown'. The default is to not set a value and to use the global default.
#   <p>Only useful together with the drbd qemu_hook in setups of two
#    redundant virtualization hosts synchronized over DRBD. They
#    have no effect if qemu_hook is not set to drbd.
# @param max_job_time
#   Maximum job time in seconds when migrating, saving or shuting down this
#   domain with the manage-domains script. The default is to not set a value
#   and to use the global default.
#   <p>Only useful together with the drbd qemu_hook in setups of two
#    redundant virtualization hosts synchronized over DRBD. They
#    have no effect if qemu_hook is not set to drbd.
# @param suspend_multiplier
#   suspend_multiplier for migrating domains with the manage-domains
#   script. The default is to not set a value and to use the global default.
#   <p>Only useful together with the drbd qemu_hook in setups of two
#   redundant virtualization hosts synchronized over DRBD. They
#   have no effect if qemu_hook is not set to drbd.
#
# @param max_memory
#   Deprecated: Maximum amount of memory that can be allocated to the domain.
#   Example (yaml):
#     domconf:
#       memory:
#         attrs:
#           unit: 'MiB'
#         values: 2000
#   **This parameter is deprecated, if set, the manifest will fail**
# @param initial_memory
#   Initial memory allocation for the domain. Defaults to max_memory.
#   Deprecation notice: use $domconf (or profile) to set.
#   Example (yaml):
#     domconf:
#       currentMemory:
#         attrs:
#           unit: 'MiB'
#         values: 1000
#   **This parameter is deprecated, if set, the manifest will fail**
# @param cpus
#   Number of virtual CPUs for the domain. Defaults to '1'.
#   Deprecation notice: use $domconf (or profile) to set.
#   Example (yaml):
#     domconf:
#       vcpu:
#         values: 1
#   **This parameter is deprecated, if set, the manifest will fail**
# @param bootmenu
#   Wheter the boot menu option should be available or not. Defaults to true.
#   Deprecation notice: use $domconf if you want to disable the bootmenu
#   Example (yaml):
#     domconf:
#       os:
#         bootmenu:
#           attrs: 
#             enable: 'no'
#   **This parameter is deprecated, if set, the manifest will fail**
# @param machine_type
#   Machine type to use, i.e.
#     * "pc" - Standard PC (i440FX + PIIX, 1996)
#     * "q35" - Standard PC (Q35 + ICH9, 2009)
#   Deprecation notice: use $domconf if you want to set the machine type
#   **This parameter is deprecated, if set, the manifest will fail**
# @param cpu_model
#   CPU model to emulate. Valid values are any cpu model accepted by libvirt or
#   the special values 'host-model' and 'host-passthrough'. See
#   http://libvirt.org/formatdomain.html#elementsCPU for details. Defaults to
#   not set a CPU at all and let libvirt choose. The values 'host-model' and
#   'host-passthrough' prevent migrations from working.
#   Deprecation notice: use $domconf (or profile) if you want to set the machine type
#   Example (yaml):
#     domconf:
#       cpu:
#         attrs:
#           mode: 'custom'
#         values:
#           model: 'SandyBridge'
#   **This parameter is deprecated, if set, the manifest will fail**
#
define libvirt::domain (
  String            $type               = 'kvm',
  String            $domain_title       = '',
  String            $description        = '',
  String            $uuid               = libvirt_generate_uuid($name),
  String            $boot               = 'hd',
  Array             $disks              = [],
  Array             $interfaces         = [],
  Boolean           $autostart          = true,
  String            $dom_profile        = 'default',
  Hash              $domconf            = {},
  String            $devices_profile    = 'default',
  Hash              $devices            = {},
  Hash              $additionaldevices  = {},
  Optional[String]  $default_host       = undef,
  Optional[String]  $evacuation         = undef,
  Optional[String]  $max_job_time       = undef,
  Optional[String]  $suspend_multiplier = undef,
  # deprecated parameters:
  Optional[Any]     $max_memory         = undef,
  Optional[Any]     $initial_memory     = undef,
  Optional[Any]     $cpus               = undef,
  Optional[Any]     $cpu_model          = undef,
  Optional[Any]     $bootmenu           = undef,
  Optional[Any]     $machine_type       = undef,
) {
  if $max_memory != undef {
    fail("deprecation: libvirt::domain, ${title}: max_memory parameter is deprecated, use domconf Hash or profile instead")
  }
  if $initial_memory != undef {
    fail("deprecation: libvirt::domain, ${title}: initial_memory parameter is deprecated, use domconf Hash or profile instead")
  }
  if $cpus != undef {
    fail("deprecation: libvirt::domain, ${title}: cpus parameter is deprecated, use domconf Hash or profile instead")
  }
  if $cpu_model != undef {
    fail("deprecation: libvirt::domain, ${title}: cpu_model parameter is deprecated, use domconf Hash or profile instead")
  }
  if $bootmenu != undef {
    fail("deprecation: libvirt::domain, ${title}: bootmenu is deprecated, use domconf Hash or profile instead")
  }
  if $machine_type != undef {
    warning("deprecation: libvirt::domain, ${title}: machine_type parameter is deprecated, use domconf Hash or profile Hash instead")
  }

  include ::libvirt
  include ::libvirt::profiles

  $devices_real  = libvirt::get_merged_profile($libvirt::profiles::devices, $devices_profile) + $devices

  if $boot == 'per-device' {
    $domconf_real  = libvirt::get_merged_profile($libvirt::profiles::domconf, $dom_profile) + $domconf
  } else {
    $_domconf = libvirt::get_merged_profile($libvirt::profiles::domconf, $dom_profile) + $domconf
    $domconf_real = deep_merge($_domconf,{'os' => {'boot' => { 'attrs' => { 'dev' => $boot }}}})
  }

  exec {"libvirt-domain-${name}":
    command  => join(['f=$(mktemp) && echo "',
                      template('libvirt/domain.xml.erb'),
                      '" > $f && virsh define $f && rm $f']),
    provider => 'shell',
    creates  => "${libvirt::config_dir}/qemu/${name}.xml",
    require  => Anchor['libvirt::end'],
  }

  if $libvirt::diff_dir != '' {
    file {"${libvirt::diff_dir}/domains/${name}.xml":
      content => template('libvirt/domain.xml.erb'),
    }
  }

  if ($autostart) {
    exec {"libvirt-domain-autostart-${name}":
      command  => "virsh autostart ${name}",
      provider => 'shell',
      creates  => "${libvirt::config_dir}/qemu/autostart/${name}.xml",
      require  => Exec["libvirt-domain-${name}"],
    }

    exec {"libvirt-domain-start-${name}":
      command  => "virsh start ${name}",
      provider => 'shell',
      unless   => "virsh list --name | grep -q ^${name}$",
      require  => Exec["libvirt-domain-${name}"],
    }
  }

  if ($libvirt::qemu_hook=='drbd') {
    concat::fragment { $name:
      target  => $libvirt::manage_domains_config,
      content => template('libvirt/manage-domains.ini.domain.erb'),
      order   => '10',
    }
  }
}
