# == Class: libvirt::params
#
# Operating system dependent parameters
class libvirt::params {
  case $::osfamily {
    'Debian': {
      case $::lsbdistcodename {
        'wheezy': {
          $libvirt_package_names  = ['libvirt-bin', 'qemu']
          $service_name           = 'libvirt-bin'
        }
        'jessie': {
          $libvirt_package_names  = ['libvirt-daemon-system', 'qemu']
          $service_name           = 'libvirtd'
        }
        'stretch': {
          $libvirt_package_names  = ['libvirt-daemon-system', 'qemu']
          $service_name           = 'libvirtd'
        }
        'buster': {
          $libvirt_package_names  = ['libvirt-daemon-system', 'qemu']
          $service_name           = 'libvirtd'
        }
        default: {
          fail("${::lsbdistcodename} is currently not supported by the libvirt
                module. Please add support for it and submit a patch!")
        }
      }
      $config_dir             = '/etc/libvirt'
      $default_dir            = '/etc/default'
      $manage_domains_config  = '/etc/manage-domains.ini'
      $qemu_hook_packages     = {'drbd' => ['xmlstarlet','python-libvirt'], }
    }

    'RedHat': {
      case $::operatingsystemmajrelease {
        '7': {
          $libvirt_package_names  = ['libvirt', 'qemu-kvm']
          $service_name           = 'libvirtd'
        }
        default: {
          fail("RedHat ${::operatingsystemmajrelease} is currently not supported by the libvirt module.
               Please add support for it and submit a patch!")
        }
      }
      $config_dir             = '/etc/libvirt'
      $default_dir            = '/etc/sysconfig'
      $manage_domains_config  = '/etc/manage-domains.ini'
      $qemu_hook_packages     = { }
    }

    default: {
      fail("${::osfamily} is currently not supported by the libvirt module.
            Please add support for it and submit a patch!")
    }
  }
}
