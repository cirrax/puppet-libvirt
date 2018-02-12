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
# [*libvirt_package_names*]
#   Array of the libvirt packages to install.
#   Defaults to $libvirt::params::libvirt_package_names
#
# [*qemu_hook_packages*]
#   Hash of Arrays of hook specific packages to install
#   Defaults to $libvirt::params::qemu_hook_packages
#
# [*qemu_conf*]
#   Hash of key/value pairs you want to put in qemu.conf file.
#
# [*qemu_hook*]
#   QEMU hook to install. The only currently available hook is a script
#   to setup DRBD resources. Valid values are 'drbd' or 'undef' (=no hook).
#   Defaults to 'undef'.
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
  $service_name          = $libvirt::params::service_name,
  $libvirt_package_names = $libvirt::params::libvirt_package_names,
  $qemu_conf             = {},
  $qemu_hook             = undef,
  $qemu_hook_packages    = $libvirt::params::qemu_hook_packages,
  $evacuation            = 'migrate',
  $max_job_time          = '120',
  $suspend_multiplier    = '5',
) inherits libvirt::params {

  Anchor['libvirt::begin'] -> Class['Libvirt::Install'] -> Class['Libvirt::Config'] -> Class['Libvirt::Service'] -> Anchor['libvirt::end']

  anchor { 'libvirt::begin': }
  include ::libvirt::install
  include ::libvirt::config
  include ::libvirt::service
  anchor { 'libvirt::end': }

  # include manage-domains script config outside of the anchor to
  # avoid dependency cycles when declaring libvirt before and
  # libvirt::domains
  if ($qemu_hook == 'drbd') {
    include ::libvirt::manage_domains_config
  }
}
