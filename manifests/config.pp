# == Class: libvirt::config
#
# Installs configuration files
class libvirt::config (
  String  $qemu_hook        = $libvirt::qemu_hook,
  Hash    $qemu_conf        = $libvirt::qemu_conf,
  Hash    $libvirtd_conf    = $libvirt::libvirtd_conf,
  Array   $uri_aliases      = $libvirt::uri_aliases,
  String  $uri_default      = $libvirt::uri_default,
  Hash    $default_conf     = $libvirt::default_conf,
  String  $config_dir       = $libvirt::config_dir,
  Boolean $drop_default_net = $libvirt::drop_default_net,
) inherits libvirt {

  if ($qemu_hook != '') {
    file {"${config_dir}/hooks/qemu":
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => "puppet:///modules/libvirt/hooks/qemu/${libvirt::qemu_hook}",
    }
  }

  if ($qemu_conf != {}) {
    file {"${config_dir}/qemu.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('libvirt/qemu.conf.erb'),
    }
  }

  if ($libvirtd_conf != {}) {
    file {"${config_dir}/libvirtd.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('libvirt/libvirtd.conf.erb'),
    }
  }

  if ( $uri_default != '' ) or ( $uri_aliases != [] ) {
    file {"${config_dir}/libvirt.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('libvirt/libvirt.conf.erb'),
    }
  }

  $default_conf.each | String $key, String $value | {
    libvirtd_default {
      $key: value => $value;
    }
  }

  if ( $drop_default_net ) {
    libvirt::network { 'default':
      ensure => 'absent',
    }
  }
}
