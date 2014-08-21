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
  $qemu_hook=undef,
  ) {

  include libvirt::params

  anchor { 'libvirt::begin': } ->
  class {'libvirt::install': } ->
  class {'libvirt::config': } ~>
  class {'libvirt::service': } ->
  anchor { 'libvirt::end': }

}
