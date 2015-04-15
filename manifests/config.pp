# == Class: libvirt::config
#
# Installs configuration files
class libvirt::config inherits libvirt {

  $_config_dir = pick($libvirt::config_dir, $params::config_dir)
  if ($libvirt::qemu_hook) {
    file {"${_config_dir}/hooks/qemu":
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => "puppet:///modules/libvirt/hooks/qemu/${libvirt::qemu_hook}",
    }
  }
}
