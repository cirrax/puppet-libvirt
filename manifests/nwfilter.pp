# libvirt::nwfilter
#
# Define a new libvirt nwfilter. The name of the nwfilter is
# the resource name. It expects an ip address and will set up
# firewalling that restricts inbound traffic to the given port
# numbers.
#
# @param uuid
#   The libvirt UUID, optional.
# @param chain
#   filter chain to use
# @param priority
#   filter priority
#   only used if template is set to generic
# @param rules
#   the filter rules to apply
#   only used if template is set to generic
# @param filterref
#   references to other filters to include
#   only used if template is set to generic
#   Example (yaml):
#   filterref:
#     - filter: 'other filter'
#     - filter: 'filter with parameter'
#       parameters:
#         - IP: '127.0.0.1',
#         - PORT: '22',
#         - PORT: '80',
# @param ip
#   The VM's IP address, mandatory.
#   only used if template is set to simple
# @param publictcpservices
#   An array with portnumbers that should be accessible over
#   TCP from anywhere
#   only used if template is set to simple
# @param publicudpservices
#   An array with portnumbers that should be accessible over
#   UDP from anywhere
#   only used if template is set to simple
# @param customtcprules
#   An array with rules that allow traffic to a specific TCP
#   port from a specific address. Syntax: 
#   `[{remote_ip => port}, ... ]`
#   only used if template is set to simple
# @param customudprules
#   An array with rules that allow traffic to a specific UDP
#   port from a specific address. Syntax:
#   `[{remote_ip => port}, ... ]`
#   only used if template is set to simple
# @param template
#   template to use. default to the 'old' simple template.
#   for new implementations you shoud use generic which is much 
#   more powerfull and should support all possible libvirt
#   configurations.
#
define libvirt::nwfilter (
  Optional[String]                      $uuid              = undef,
  Libvirt::Nwfilter::Chain              $chain             = 'root',
  Optional[Libvirt::Nwfilter::Priority] $priority          = undef,
  Libvirt::Nwrules                      $rules             = [],
  Libvirt::Filterref                    $filterref         = [],
  Optional[String]                      $ip                = undef,
  Array                                 $publictcpservices = [],
  Array                                 $publicudpservices = [],
  Array                                 $customtcprules    = [],
  Array                                 $customudprules    = [],
  Enum['simple','generic']              $template          = 'simple',
) {
  include libvirt

  $require_service = $libvirt::service_name ? {
    Undef   => undef,
    default => Service[$libvirt::service_name],
  }

  if $template == 'simple' {
    $content = libvirt::normalxml(template('libvirt/nwfilter/simple.xml.erb'))
  } else {
    $content = epp('libvirt/nwfilter/generic.xml.epp', {
        filtername => $title,
        chain      => $chain,
        priority   => pick($priority, $libvirt::filter_default_prio[$chain], 500),
        rules      => $rules,
        filterref  => $filterref,
    })
  }

  libvirt_nwfilter { $title:
    content => $content,
    uuid    => $uuid,
  }

  if $libvirt::diff_dir {
    file { "${libvirt::diff_dir}/nwfilters/${title}.xml":
      content => $content,
    }
  }
}
