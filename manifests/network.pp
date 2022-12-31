# libvirt::network
#
# @summary Define a new libvirt network. The name of the network is
#   the resource name.
#
# @note Most parameters are modeled after their equivalents in the libvirt
#   network XML definition. See http://libvirt.org/formatnetwork.html
#   for more information.
# @note the are two different templates to generate the xml
#   The 'simple' template is the older erb template which does not
#   support all possible options.
#   The 'generic' template is a newer epp template which should
#   support all options. For new networks, use the generic template 
#   which is more future proof !
#
# @param ensure
#   if we ensure the network present or absent.
# @param metadata
#   Network metadata
#   only used for the 'generic' template
# @param bridge
#   Name of the bridge device to use for this network as String or a
#   Hash of attributes for the 'bridge' with 'name' attribute beeing mandatory.
#   The default simple template only supports string.
# @param domain
#   DNS domain of the DHCP server
#   only used for the 'generic' template
# @param forward
#   Determines the method of forwarding
#   only used for the 'generic' template
# @param bandwith
#   setting quality of service for a particular network 
#   only used for the 'generic' template
# @param vlan
#   vlan tags
#   only used for the 'generic' template
# @param port
#   for port isolation
#   only used for the 'generic' template
# @param ips
#   ip adresses
#   only used for the 'generic' template
# @param routes
#   routes
#   only used for the 'generic' template
# @param dns
#   dns
#   only used for the 'generic' template
# @param dnsmasq_options
#   options for dnsmasq
#   only used for the 'generic' template
# @param virtualport
#   virtual port
#   only used for the 'generic' template
# @param forward_mode
#   Network forward mode. Valid modes are 'nat', 'route', 'bridge', 'private',
#   'vepa', 'passthrough' and 'hostdev'. The default is 'bridge'.
#   only used for the 'simple' template
# @param virtualport_type
#   Set this to 'openvswitch' for an Open vSwitch bridge. Leave undefined
#   otherwise.
#   only used for the 'simple' template
# @param portgroups
#   Array of hashes defining portgroups. This only works for Open vSwitch
#   networks. The hash supports the following keys (for the simple template):
#   * name:     Name of the portgroup.
#   * trunk:    Set to true if this is a trunk port. In this case, the
#               vlan_tag element must contain an array of allowed VLAN
#               tags.
#   * vlan_tag: VLAN tag for this portgroup.
#   to use all possible portgroup values you need to use the generic template.
# @param autostart
#   Wheter to start this network on boot or not. Defaults to true.
# @param forward_dev
#   The interface to forward, useful in bridge and route mode
#   only used for the 'simple' template
# @param forward_interfaces
#   An array of interfaces to forwad
#   only used for the 'simple' template
# @param ip_address
#   The ip address for the device
#   only used for the 'simple' template
# @param ip_netmask
#   The netmask for the ip address
#   only used for the 'simple' template
# @param dhcp_start
#   Optional dhcp range start
#   only used for the 'simple' template
# @param dhcp_end
#   Optional dhcp range end
#   only used for the 'simple' template
# @param dns_enable
#   Set this to 'no' to disable the DNS service. Leave undefined otherwise.
#   only used for the 'simple' template
# @param mtu
#   Set a custom mtu value. Default depending on the setting of the type of
#   device being used, usually 1500.
# @param template
#    template to use to create the network xml
# @param show_diff
#   set to false, if you do not want to see the changes
#
define libvirt::network (
  Enum['present','absent']                 $ensure             = 'present',
  Optional[Libvirt::Net::Metadata]         $metadata           = undef,
  Optional[Libvirt::Net::Bridge]           $bridge             = undef,
  Optional[Libvirt::Net::Domain]           $domain             = undef,
  Optional[Libvirt::Net::Forward]          $forward            = undef,
  Optional[Libvirt::Net::Bandwith]         $bandwith           = undef,
  Optional[Libvirt::Net::Vlan]             $vlan               = undef,
  Optional[Libvirt::Net::Port]             $port               = undef,
  Array[Optional[Libvirt::Net::Ip]]        $ips                = [],
  Array[Optional[Libvirt::Net::Route]]     $routes             = [],
  Optional[Libvirt::Net::Dns]              $dns                = undef,
  Optional[Libvirt::Net::Dnsmasq_options]  $dnsmasq_options    = undef,
  Optional[Libvirt::Net::Virtualport]      $virtualport        = undef,
  Array[Optional[Libvirt::Net::Portgroup]] $portgroups         = [],
  String                                   $forward_mode       = 'bridge',
  Optional[String]                         $forward_dev        = undef,
  Array                                    $forward_interfaces = [],
  Optional[String]                         $virtualport_type   = undef,
  Boolean                                  $autostart          = true,
  Optional[String]                         $ip_address         = undef,
  Optional[String]                         $ip_netmask         = undef,
  Optional[String]                         $dhcp_start         = undef,
  Optional[String]                         $dhcp_end           = undef,
  Optional[String]                         $dns_enable         = undef,
  Optional[Integer]                        $mtu                = undef,
  Enum['simple','generic']                 $template           = 'simple',
  Boolean                                  $show_diff          = true,
) {
  include libvirt

  if ($ensure != 'absent') {
    if $template == 'generic' {
      $content = libvirt::normalxml(epp('libvirt/network/generic.xml.epp', {
            'networkname' => $title,
            'tree'        => $libvirt::tree_network,
            'metadata'    => $metadata,
            'mtu'         => $mtu,
            'bridge'      => $bridge,
            'domain'      => $domain,
            'forward'     => $forward,
            'bandwith'    => $bandwith,
            'vlan'        => $vlan,
            'port'        => $port,
            'portgroups'  => $portgroups,
            'ips'         => $ips,
            'routes'      => $routes,
            'dns'         => $dns,
            'dnsmasq_options' => $dnsmasq_options,
            'virtualport'     => $virtualport,
      }))
    } else {
      if ! ($bridge =~ Undef or $bridge =~ String) {
        fail("network['${name}']: simple template does support Strings for bridge parameter only")
      }
      $content = libvirt::normalxml(template('libvirt/network/simple.xml.erb'))
    }
  } else {
    $content = ''
  }

  libvirt_network { $title:
    ensure    => $ensure,
    content   => $content,
    autostart => $autostart,
    show_diff => $show_diff,
  }

  if $libvirt::diff_dir {
    file { "${libvirt::diff_dir}/networks/${name}.xml":
      ensure  => $ensure,
      content => $content,
    }
  }
}
