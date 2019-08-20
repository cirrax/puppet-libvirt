# libvirt::install
#
# @summary Installs the required packages and files
#
# @param qemu_hook
#   QEMU hook to install. The only currently available hook is a script
#   to setup DRBD resources. Valid values are 'drbd' or '' (=no hook).
#   Default inherited from ::libvirt class
#
# @param packages
#   Array of the libvirt package names to install.
#   Default inherited from ::libvirt class
#
# @param qemu_hook_packages
#   Hash of Arrays of hook specific packages to install
#   Default inherited from ::libvirt class
#
# @param package_ensure
#   What state the packages should be in.
#   Defaults to 'installed'
#
class libvirt::install (
  String $qemu_hook          = $libvirt::qemu_hook,
  Array  $packages           = $libvirt::libvirt_package_names,
  Hash   $qemu_hook_packages = $libvirt::qemu_hook_packages,
  String $package_ensure     = 'installed',
) inherits libvirt {

  package { $packages:
    ensure => $package_ensure,
  }

  # install hook specific packages
  if ($qemu_hook_packages[$qemu_hook]) {
    package {$qemu_hook_packages[$qemu_hook]:
      ensure => $package_ensure,
    }
  }

  # install managment script for drbd hook
  if ($qemu_hook == 'drbd') {
    file {'/usr/local/sbin/manage-domains':
      ensure => 'present',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/libvirt/scripts/manage-domains',
    }
  }
}
