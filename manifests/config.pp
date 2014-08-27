# == Class: libvirt::config
#
# Installs configuration files
class libvirt::config inherits libvirt {

  if ($qemu_hook) {
    file {"${params::config_dir}/hooks/qemu":
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => "puppet:///modules/libvirt/hooks/qemu/${qemu_hook}",
    }
  }
}
