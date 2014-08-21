# == Class: libvirt::config
#
# Installs configuration files
class libvirt::config inherits libvirt {

  if ($qemu_hook) {
    file {"${params::config_dir}/hooks/qemu":
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => "puppet:///modules/libvirt/hooks/qemu/${qemu_hook}",
    }
    if ($params::qemu_hook_packages[$qemu_hook]) {
      package {$params::qemu_hook_packages[$qemu_hook]:
        ensure => 'installed',
      }
    }
  }

}
