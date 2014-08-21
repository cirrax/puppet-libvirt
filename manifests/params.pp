# == Class: libvirt::params
#
# Operating system dependent parameters
class libvirt::params {
  if ($::osfamily == 'Debian') {
    $libvirt_package_names  = ['libvirt-bin', 'qemu']
    $service_name           = 'libvirt-bin'
    $config_dir             = '/etc/libvirt'
    $qemu_hook_packages     = {'drbd' => ['xmlstarlet',], }
  } else {
    fail("${::osfamily} is currently not supported by the libvirt module.
      Please add support for it and submit a patch!")
  }
}
