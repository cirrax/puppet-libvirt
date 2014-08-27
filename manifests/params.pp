# == Class: libvirt::params
#
# Operating system dependent parameters
class libvirt::params {
  if ($::osfamily == 'Debian') {
    $libvirt_package_names  = ['libvirt-bin', 'qemu']
    $service_name           = 'libvirt-bin'
    $config_dir             = '/etc/libvirt'
    $manage_domains_config  = '/etc/manage-domains.ini'
    $qemu_hook_packages     = {'drbd' => ['xmlstarlet','python-libvirt'], }
  } else {
    fail("${::osfamily} is currently not supported by the libvirt module.
      Please add support for it and submit a patch!")
  }
}
