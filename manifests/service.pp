# == Class: libvirt::service
#
# Installs services
#
# === Parameters
#
# [*service_name*]
#   Service name for libvirt. The default value is Distribution specific
#   and inherited from ::libvirt class.
#
# [*service_ensure*]
#   Whether the service should be running.
#   Defaults to 'running'
#
# [*service_enable*]
#   Whether the service should be enabled.
#   Defaults to true
#
# [*manage_service*]
#   Whether the service should be managed at all.
#   Defaults to true
#
class libvirt::service(
  String  $service_name   = $libvirt::service_name,
  String  $service_ensure = $libvirt::service_ensure,
  Boolean $service_enable = $libvirt::service_enable,
  Boolean $manage_service = $libvirt::manage_service,
) inherits libvirt {

  if $manage_service {
    service {'libvirtd':
      ensure => $service_ensure,
      name   => $service_name,
      enable => $service_enable,
    }
  }
}
