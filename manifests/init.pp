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
  $qemu_hook          = undef,
  $evacuation         = 'migrate',
  $max_job_time       = '120',
  $suspend_multiplier = '5',
  ) {

  include libvirt::params

  anchor { 'libvirt::begin': } ->
  class {'libvirt::install': } ->
  class {'libvirt::config': } ~>
  class {'libvirt::service': } ->
  anchor { 'libvirt::end': }

  # include manage-domains script config outside of the anchor to
  # avoid dependency cycles when declaring libvirt before and
  # libvirt::domains
  if ($qemu_hook == 'drbd') {
    class {'libvirt::manage_domains_config': }
  }
}
