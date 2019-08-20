# libvirt::service
#
# @summary Installs services
#
# @param service_name
#   Service name for libvirt. The default value is Distribution specific
#   and inherited from ::libvirt class.
#
# @param service_ensure
#   Whether the service should be running.
#   Defaults to 'running'
#
# @param service_enable
#   Whether the service should be enabled.
#   Defaults to true
#
# @param manage_service
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
    Libvirtd_conf <| |> ~> Service['libvirtd']

    service {'libvirtd':
      ensure => $service_ensure,
      name   => $service_name,
      enable => $service_enable,
    }
  }
}
