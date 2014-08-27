# == Class: libvirt::install
#
# Installs the required packages and files
class libvirt::install inherits libvirt {

  package {$params::libvirt_package_names:
    ensure => 'installed',
  }

  # install hook specific packages
  if ($params::qemu_hook_packages[$qemu_hook]) {
    package {$params::qemu_hook_packages[$qemu_hook]:
      ensure => 'installed',
    }
  }

  # install managment script for drbd hook
  if ($libvirt::qemu_hook == 'drbd') {
    file {'/usr/local/sbin/manage-domains':
      ensure => 'present',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/libvirt/scripts/manage-domains',
    }
  }
}
