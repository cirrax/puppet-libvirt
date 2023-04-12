#
# Libvirt (http://libvirt.org/) Puppet module
#
# @summary this is the main class, used configure libvirt.
#
# @param service_name
#   Service name for libvirt. The default value is Distribution specific.
#   Only set this if your setup differs from the packages provided by
#   your distribution.
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
#   Whether the service should be managed by this module.
#   Defaults to true
#
# @param libvirt_package_names
#   Array of the libvirt packages to install.
#   Required, see hiera data directory for defaults
#
# @param qemu_conf
#   Hash of key/value pairs you want to put in qemu.conf file.
#
# @param qemu_hook
#   QEMU hook to install. The only currently available hook is a script
#   to setup DRBD resources. Valid values are 'drbd' or `undef` (=no hook).
#   Defaults to `undef`.
#
# @param qemu_hook_packages
#   Hash of Arrays of hook specific packages to install
#   see hiera data directory for defaults
#
# @param create_networks
#   Hash of networks to create with libvirt::network
#   Defaults to {}
#
# @param create_domains
#   Hash of domains to create with libvirt::domain
#   Defaults to {}
#
# @param create_nwfilters
#   Hash of nwfilters to create with libvirt::nwfilter
#   Defaults to {}
#
# @param create_pools
#   Hash of pools to create with libvirt_pool
#   Defaults to {}
#
# @param evacuation
#   Default evacuation policy to shutdown or migrate all domains on a host.
#   Valid values are 'migrate', 'save' and 'shutdown'. This can be overriden
#   on a per domain basis. The default value is 'migrate'.
#   <p>Only useful together with the drbd qemu_hook in setups of two
#   redundant virtualization hosts synchronized over DRBD. They
#   have no effect if qemu_hook is not set to drbd.
# @param max_job_time
#   Default maximum job time in seconds when migrating, saving or shuting down
#   domains with the manage-domains script. This can be overriden on a per
#   domain basis. The default is 120.
#   <p>Only useful together with the drbd qemu_hook in setups of two
#   redundant virtualization hosts synchronized over DRBD. They
#   have no effect if qemu_hook is not set to drbd.
# @param suspend_multiplier
#   Default suspend_multiplier for migrating domains with the manage-domains
#   script. This can be overriden on a per domain basis. The default is 5.
#   <p>Only useful together with the drbd qemu_hook in setups of two
#   redundant virtualization hosts synchronized over DRBD. They
#   have no effect if qemu_hook is not set to drbd.
# @param migration_url_format
#   url format for to use for migration. default is ssh
#   possible values:
#   ssh: gives an url: 'qemu+ssh://%s/system'
#   tls: gives an url: 'qemu+tls://%s/system'
#   alias: sepcify the url as an alias in /etc/libvirt.conf
# @param uri_aliases
#   define aliases for a client to connect 
#   defaults to []
# @param uri_default
#   the default url to use.
#   defaults to `undef` (which means the system default is used)
# @param default_conf
#   Hash to add config to /etc/default/libvirtd (Debian) or
#   /etc/sysconfig/libvirtd (RedHat)
#   Defaults to {}
# @param libvirtd_conf
#   Hash to add config to /etc/libvirt/libvirtd.conf 
#   Defaults to {}
# @param config_dir
#   the directory for configurations.
#   Defaults to '/etc/libvirt'
# @param manage_domains_config
#   configuration file for managing domains.
#   Defaults to '/etc/manage-domains.ini'
# @param drop_default_net
#   Boolean, if  true, purges the default network
#   Deprecated, use $purge_network if you like to drop
#   networks not managed with puppet.
# @param diff_dir
#   if this is set to a path, the directory is created and
#   the xmls generated for the domains are kept and diffs
#   are shown on changes by puppet.
#   usefull for development (or on upgrade)
#   defaults to `undef` (== disabled)
# @param filter_default_prio
#   default filter priorities per filter chain.
#   defaults are taken from hiera.
# @param default_nwfilters
#   hash of default filters to load
#   this parameter is hash merged.
# @param load_nwfilter_set
#   set of nwfilters to load
#   this loads (create_resources) of all filters defined
#   in $load_nwfilter_set.each |$i| {$default_nwfilters[$i]}
#   see data/profiles/nwfilter_* for supported sets of filter
#   will set the default template to 'generic'
# @param purge_nwfilter
#   what to do with nwfilters not managed with puppet:
#    none: we do not care
#    purge: remove the filters
#    noop: warn (do a purge with noop parameter)
# @param purge_network
#   what to do with persistent networks not managed with puppet:
#    none: we do not care
#    purge: remove the network
#    noop: warn (do a purge with noop parameter)
#   Remark: non persistent networks are not affected.
#   only persisten network are handled within this module.   
# @param purge_domain
#   what to do with persistent domains not managed with puppet:
#    none: we do not care
#    purge: remove the domain
#    noop: warn (do a purge with noop parameter)
#   Remark: non persistent domains are not affected.
#   only persisten domains are handled within this module.
# @param tree_network
#   this is the tree of all elements available for network
#   xml definition, which stears the xml generation
#   everything not defined as element is treated as attribute.
#   There is no need to change this !! Better file a bug !
#
# @example using a drbd hook
#   class { 'libvirt':
#     qemu_hook => 'drbd',
#     qemu_conf => {
#       'vnc_listen' => '0.0.0.0'
#     }
#   }
#
class libvirt (
  Array                                                $libvirt_package_names = [],
  String                                               $service_name          = 'libvirtd',
  String                                               $service_ensure        = 'running',
  Boolean                                              $service_enable        = true,
  Boolean                                              $manage_service        = true,
  Hash                                                 $qemu_conf             = {},
  Optional[String]                                     $qemu_hook             = undef,
  Hash                                                 $qemu_hook_packages    = {},
  Hash                                                 $create_networks       = {},
  Hash                                                 $create_domains        = {},
  Hash                                                 $create_nwfilters      = {},
  Hash                                                 $create_pools          = {},
  String                                               $evacuation            = 'migrate',
  String                                               $max_job_time          = '120',
  String                                               $suspend_multiplier    = '5',
  String                                               $migration_url_format  = 'ssh',
  Array                                                $uri_aliases           = [],
  Optional[String]                                     $uri_default           = undef,
  Hash                                                 $default_conf          = {},
  Hash[Optional[String],Variant[String,Integer,Array]] $libvirtd_conf         = {},
  String                                               $config_dir            = '/etc/libvirt',
  String                                               $manage_domains_config = '/etc/manage-domains.ini',
  Boolean                                              $drop_default_net      = false,
  Optional[String]                                     $diff_dir              = undef,
  Hash                                                 $filter_default_prio   = {},
  Hash[String[1], Hash]                                $default_nwfilters     = {},
  Array[String[1]]                                     $load_nwfilter_set     = [],
  Enum['none','purge','noop']                          $purge_nwfilter        = 'none',
  Enum['none','purge','noop']                          $purge_network         = 'none',
  Enum['none','purge','noop']                          $purge_domain          = 'none',
  Hash                                                 $tree_network          = {},
) {
  # dependencies
  Class['Libvirt::Install']
  -> Class['Libvirt::Config']
  -> Service<| tag == 'libvirt' |>  # libvirt automatic tag !
  -> Libvirt_network<| |>
  -> Libvirt_nwfilter<| |>
  -> Libvirt_domain<| |>

  include libvirt::install
  include libvirt::config
  include libvirt::service

  # include manage-domains script config outside of the anchor to
  # avoid dependency cycles when declaring libvirt before and
  # libvirt::domains
  if ($qemu_hook == 'drbd') {
    include libvirt::manage_domains_config
  }

  if $diff_dir {
    file { [$diff_dir, "${diff_dir}/domains", "${diff_dir}/networks", "${diff_dir}/nwfilters"]:
      ensure  => directory,
      purge   => true,
      recurse => true,
    }
  }

  # do nwfilter purge (if configured)
  if $purge_nwfilter == 'purge' {
    resources { 'libvirt_nwfilter':
      purge => true,
    }
  } elsif $purge_nwfilter == 'noop' {
    resources { 'libvirt_nwfilter':
      purge => true,
      noop  => true,
    }
  }

  # do network purge (if configured !)
  if $purge_network == 'purge' {
    resources { 'libvirt_network':
      purge => true,
    }
  } elsif $purge_network == 'noop' {
    resources { 'libvirt_network':
      purge => true,
      noop  => true,
    }
  }

  # do domain purge (if configured !)
  if $purge_domain == 'purge' {
    resources { 'libvirt_domain':
      purge => true,
    }
  } elsif $purge_domain == 'noop' {
    resources { 'libvirt_domain':
      purge => true,
      noop  => true,
    }
  }

  create_resources('::libvirt::network', $create_networks)
  create_resources('::libvirt::domain', $create_domains)
  create_resources('::libvirt::nwfilter', $create_nwfilters)
  create_resources('libvirt_pool', $create_pools)

  $load_nwfilter_set.each | String[1] $i| {
    create_resources('libvirt::nwfilter', $default_nwfilters[$i], {
        'template' => 'generic',
    })
  }

  if ( $drop_default_net ) {
    warning('deprecation: libvirt::drop_default_net parameter will be deprecated in future version, use purge_network parameter instead')
    libvirt::network { 'default':
      ensure => 'absent',
    }
  }
}
