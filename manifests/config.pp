# == Class: libvirt::config
#
# Installs configuration files
class libvirt::config (
  $qemu_hook   = $libvirt::qemu_hook,
  $qemu_conf   = $libvirt::qemu_conf,
  $uri_aliases = $libvirt::uri_aliases,
  $uri_default = $libvirt::uri_default,
) inherits libvirt {

  include ::libvirt::params

  if ($qemu_hook) {
    file {"${libvirt::params::config_dir}/hooks/qemu":
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => "puppet:///modules/libvirt/hooks/qemu/${libvirt::qemu_hook}",
    }
  }

  if ($qemu_conf != {}) {
    file {"${libvirt::params::config_dir}/qemu.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('libvirt/qemu.conf'),
    }
  }

  if ( $uri_default != '' ) or ( $uri_aliases != [] ) {
    file {"${libvirt::params::config_dir}/libvirt.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('libvirt/libvirt.conf.erb'),
    }
  }

}
