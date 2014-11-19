# == Class: libvirt::service
#
# Installs services
class libvirt::service inherits libvirt {

  $_service_name = pick($libvirt::service_name, $params::service_name)
  service {$_service_name:
    ensure => 'running',
  }
}
