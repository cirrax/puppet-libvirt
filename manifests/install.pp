# == Class: libvirt::install
#
# Installs the required packages
class libvirt::install inherits libvirt {

  package {$params::libvirt_package_names:
    ensure => 'installed',
  }

}
