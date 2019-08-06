# == Class: libvirt
#
# Libvirt (http://libvirt.org/) Puppet module
#
# This module currently only supports basic configuration of libvirt
# and definition of virtual machines. Changing existing virtual machines
# is not (yet) supported.
#
# Currently only Debian is supported. Patches to support other operating
# systems or which add new features are welcome.
#
# === Parameters
#
# [*service_name*]
#   Service name for libvirt. The default value is Distribution specific.
#   Only set this if your setup differs from the packages provided by
#   your distribution.
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
#   Whether the service should be managed by this module.
#   Defaults to true
#
# [*libvirt_package_names*]
#   Array of the libvirt packages to install.
#   Required, see hiera data directory for defaults
#
# [*qemu_hook_packages*]
#   Hash of Arrays of hook specific packages to install
#   Defaults to {}
#
# [*qemu_conf*]
#   Hash of key/value pairs you want to put in qemu.conf file.
#
# [*qemu_hook*]
#   QEMU hook to install. The only currently available hook is a script
#   to setup DRBD resources. Valid values are 'drbd' or '' (=no hook).
#   Defaults to ''.
#
# [*qemu_hook_packages*]
#   Hash of Arrays of hook specific packages to install
#   see hiera data directory for defaults
#
# [*create_networks*]
#   Hash of networks to create with libvirt::network
#   Defaults to {}
#
# [*create_domains*]
#   Hash of domains to create with libvirt::domain
#   Defaults to {}
#
# [*create_nwfilters*]
#   Hash of nwfilters to create with libvirt::nwfilter
#   Defaults to {}
#
# [*libvirtd_conf*]
#   Hash of key/value pairs you want to put in libvirtd.conf file.
#
# The following values are only useful together with the drbd qemu_hook in
# setups of two redundant virtualization hosts synchronized over DRBD. They
# have no effect if qemu_hook is not set to drbd.
#
# [*evacuation*]
#   Default evacuation policy to shutdown or migrate all domains on a host.
#   Valid values are 'migrate', 'save' and 'shutdown'. This can be overriden
#   on a per domain basis. The default value is 'migrate'.
# [*max_job_time*]
#   Default maximum job time in seconds when migrating, saving or shuting down
#   domains with the manage-domains script. This can be overriden on a per
#   domain basis. The default is 120.
# [*suspend_multiplier*]
#   Default suspend_multiplier for migrating domains with the manage-domains
#   script. This can be overriden on a per domain basis. The default is 5.
# [*migration_url_format*]
#   url format for to use for migration. default is ssh
#   possible values:
#   ssh: gives an url: 'qemu+ssh://%s/system'
#   tls: gives an url: 'qemu+tls://%s/system'
#   alias: sepcify the url as an alias in /etc/libvirt.conf
# [*uri_aliases*]
#   define aliases for a client to connect 
#   defaults to []
# [*uri_default*]
#   the default url to use.
#   defaults to '' (which means the system default is used)
# [*default_conf*]
#   Hash to add config to /etc/default/libvirtd (Debian) or
#   /etc/sysconfig/libvirtd (RedHat)
#   Defaults to {}
# [*config_dir*]
#   the directory for configurations.
#   Defaults to '/etc/libvirt'
# [*manage_domains_config*]
#   configuration file for managing domains.
#   Defaults to '/etc/manage-domains.ini'
# [*drop_default_net*]
#   Boolean, don't create default network and bridge (virbr0)
#   Defaults to false
# [*diff_dir*]
#   if this is set to a path, the directory is created and
#   the xmls generated for the domains are kept and diffs
#   are shown on changes by puppet.
#   usefull for development (or on upgrade)
#   defaults to '' (== disabled)
#
# === Examples
#
#  class { 'libvirt':
#    qemu_hook => 'drbd',
#    qemu_conf => {
#     'vnc_listen' => '0.0.0.0'
#    }
#  }
#
# === Authors
#
# Gaudenz Steinlin <gaudenz.steinlin@cirrax.com>
#
# === Copyright
#
# Copyright 2014 Cirrax GmbH
#
class libvirt (
  Array   $libvirt_package_names = [],
  String  $service_name          = 'libvirtd',
  String  $service_ensure        = 'running',
  Boolean $service_enable        = true,
  Boolean $manage_service        = true,
  Hash    $qemu_conf             = {},
  String  $qemu_hook             = '',
  Hash    $qemu_hook_packages    = {},
  Hash    $create_networks       = {},
  Hash    $create_domains        = {},
  Hash    $create_nwfilters      = {},
  Hash    $libvirtd_conf         = {},
  String  $evacuation            = 'migrate',
  String  $max_job_time          = '120',
  String  $suspend_multiplier    = '5',
  String  $migration_url_format  = 'ssh',
  Array   $uri_aliases           = [],
  String  $uri_default           = '',
  Hash    $default_conf          = {},
  String  $config_dir            = '/etc/libvirt',
  String  $manage_domains_config = '/etc/manage-domains.ini',
  Boolean $drop_default_net      = false,
  String  $diff_dir              = '',
) {

  Anchor['libvirt::begin'] -> Class['Libvirt::Install'] -> Class['Libvirt::Config'] -> Class['Libvirt::Service'] -> Anchor['libvirt::installed'] -> Anchor['libvirt::end']

  anchor { 'libvirt::begin': }
  include ::libvirt::install
  include ::libvirt::config
  include ::libvirt::service
  anchor { 'libvirt::installed': }
  anchor { 'libvirt::end': }

  # include manage-domains script config outside of the anchor to
  # avoid dependency cycles when declaring libvirt before and
  # libvirt::domains
  if ($qemu_hook == 'drbd') {
    include ::libvirt::manage_domains_config
  }

  if $diff_dir != '' {
    file{ [ $diff_dir, "${diff_dir}/domains", "${diff_dir}/networks", "${diff_dir}/nwfilters" ]:
      ensure  => directory,
      purge   => true,
      recurse => true,
    }
  }

  create_resources('::libvirt::network', $create_networks)
  create_resources('::libvirt::domain', $create_domains)
  create_resources('::libvirt::nwfilter', $create_nwfilters)
}
