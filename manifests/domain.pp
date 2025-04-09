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
# @param ensure
#   if we ensure the VM present or absent.
# @param type
#   Specify the hypervisor used for running the domain.
#   The allowed values are driver specific, but include "xen", "kvm", "qemu" and "lxc"
#   Defaults to 'kvm'
# @param domain_title
#   Free text title of the domain. Defaults to `undef`.
# @param description
#   Free text description of the domain. Defaults to `undef`.
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
#
#   Hint: if a special configuration is not possible using this parameter, you can use the
#         $devices or $additionadevices parameter which make any configuration libvirt supports possible
# @param interfaces
#   Array of hashes defining the network interfaces of this domain. Defaults to
#   no network interfaces.
#   The hashes support the following keys:
#     * interface_type: the type of the interface, currently supported:
#                       'network', 'bridge', 'vdpa', 'mcast', 'server', 'client', 'null', 'vds',
#                       defaults to 'network' if unset.
#     * mac:            MAC address of the interface. Without a mac key, a random
#                       address will be assigned by libvirt. The MAC address should
#                       start with 52:54:00.
#     * source:         Hash of the source (network/bridge to attach to) (optional)
#                       this will translate to keyX = valueX for all key value pairs
#                       in the hash added as attributes to the source tag in the resulting XML
#     * address:        Hash of the address sub-element to decribe where the device is placed on the
#                       virtual bus presented to the guest.
#     * type:           Type of network card. Defaults to 'virtio'.
#     * boot_order:     Integer starting at 1 for the highest priority (shared with
#                       disks).
#     Deprecated keys:
#     * network:        libvirt network to attach to (optional, depracated, use source).
#                       instead of this parameter, use source = { '[network|bridge]' => NETWORK }
#     * portgroup:      portgroup to attach to (optional, deprecated, use source).
#                       instead of this parameter, use source = { '[network|bridge]' => NETWORK, 'portgroup' => 'GROUP }
#
#   Hint: if a special configuration is not possible using this parameter, you can use the
#         $devices or $additionadevices parameter which make any configuration libvirt supports possible
# @param autostart
#   Wheter the libvirt autostart flag should be set. Defaults to true. Autostart
#   domains are started if the host is booted.
# @param active
#   If true, this ensures the VM is running, if false ensures the machine
#   is not running. Default: undef
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
#   Hint: This parameters allows to configure disks/network interfaces also
# @param additionaldevices
#   additional devices to attach to the vm
#   Same format as $devices, but without merging.
#   Defaults to {}
#   Hint: This parameters allows to configure disks/network interfaces also
# @param replace
#   set this to true if you like to replace existing VM
#   configurations with puppet definitions (or if you change the config in puppet)
#   To avoid replacement in each puppet run, this needs to set the libvirt::domain::ignore
#   parameter according the VM definition to filter the XML generated by virsh
#   (virsh adds some state and automatic dependency information to the dumped XML).
#   Since libvirt does not only add state information to result of the dumpxml command
#   (which can be handled with the $ignore parameter)
#   but does also not display certain elements used to generate a domain this functionality
#   is not yet very usefull. 
# @param ignore_profile
#   the profile to take for the ignore parameters
# @param ignore
#   Array Xpath definitions to ignore when comparing the
#   configured with the persistent/running configuration of a domain.
#   Libvirt add some default configurations which should not be included
#   in the XML we compare.
#   This is merged with the configured profile (value of $ignore_profile).
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
# @param show_diff
#   set to false, if you do not want to see the changes
#
define libvirt::domain (
  Enum['present','absent']                $ensure             = 'present',
  String[1]                               $type               = 'kvm',
  Optional[String]                        $domain_title       = undef,
  Optional[String]                        $description        = undef,
  String[1]                               $uuid               = libvirt_generate_uuid($name),
  String[1]                               $boot               = 'hd',
  Array[Libvirt::Domain::Disk]            $disks              = [],
  Array[Libvirt::Domain::Interface]       $interfaces         = [],
  Boolean                                 $autostart          = true,
  Optional[Boolean]                       $active             = undef,
  String[1]                               $dom_profile        = 'default',
  Hash                                    $domconf            = {},
  String[1]                               $devices_profile    = 'default',
  Hash[String[1],Libvirt::Domain::Device] $devices            = {},
  Hash[String[1],Libvirt::Domain::Device] $additionaldevices  = {},
  Boolean                                 $replace            = false,
  String[1]                               $ignore_profile     = 'default',
  Array[String[1]]                        $ignore             = [],
  Optional[String[1]]                     $default_host       = undef,
  Optional[String[1]]                     $evacuation         = undef,
  Optional[String[1]]                     $max_job_time       = undef,
  Optional[String[1]]                     $suspend_multiplier = undef,
  Boolean                                 $show_diff          = true,
) {
  include libvirt
  include libvirt::profiles

  $devices_real  = libvirt::get_merged_profile($libvirt::profiles::devices, $devices_profile) + $devices

  if $boot == 'per-device' {
    $domconf_real  = libvirt::get_merged_profile($libvirt::profiles::domconf, $dom_profile) + $domconf
  } else {
    $_domconf = libvirt::get_merged_profile($libvirt::profiles::domconf, $dom_profile) + $domconf
    $domconf_real = deep_merge($_domconf, { 'os' => { 'boot' => { 'attrs' => { 'dev' => $boot } } } })
  }

  $content = libvirt::normalxml(template('libvirt/domain.xml.erb'))

  libvirt_domain { $title :
    ensure    => $ensure,
    content   => $content,
    autostart => $autostart,
    active    => $active,
    show_diff => $show_diff,
    replace   => $replace,
    ignore    => $libvirt::profiles::ignore[$ignore_profile] + $ignore,
    tag       => 'libvirt',
  }

  if $libvirt::diff_dir {
    file { "${libvirt::diff_dir}/domains/${name}.xml":
      ensure  => $ensure,
      content => $content,
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
