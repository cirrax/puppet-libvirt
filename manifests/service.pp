# == Class: libvirt::service
#
# Installs services
class libvirt::service inherits libvirt {

  service {$params::service_name:
    ensure => 'running',
  }
}
