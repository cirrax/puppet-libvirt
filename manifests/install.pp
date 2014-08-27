# == Class: libvirt::install
#
# Installs the required packages
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
}
