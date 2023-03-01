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
# @param modular_services
#   Hash of `service` resources for [modular drivers and sockets](https://libvirt.org/daemons.html#modular-driver-daemons).
#   When this is set, `service_name`, `service_ensure`, and `service_enable` are ignored.
#   Services tagged with libvirt-libvirtd-conf are notified from changes in Libvirtd_conf.
#
#   Example usage: Use the following snippet, if your libvirtd>5.6.0 and you like TLS socket usage 
#   (former --listen and TLS option):
#     libvirt::service::modular_services:
#       libvirtd.service:
#         enable: false
#         tag: 'libvirt-libvirtd-conf'
#       libvirtd-tls.socket:
#         ensure: 'running'
#         enable: true
#
class libvirt::service (
  String                          $service_name     = $libvirt::service_name,
  String                          $service_ensure   = $libvirt::service_ensure,
  Boolean                         $service_enable   = $libvirt::service_enable,
  Boolean                         $manage_service   = $libvirt::manage_service,
  Optional[Hash[String[1], Hash]] $modular_services = undef,
) inherits libvirt {
  if $manage_service {
    Libvirtd_conf <| |> ~> Service<| tag=='libvirt-libvirtd-conf' |>

    pick($modular_services, { 'libvirtd' => {
          'ensure' => $service_ensure,
          'name'   => $service_name,
          'enable' => $service_enable,
          'tag'    => 'libvirt-libvirtd-conf',
    } }).each |$key, $value| {
      service { $key:
        * => $value,
      }
    }
  }
}
