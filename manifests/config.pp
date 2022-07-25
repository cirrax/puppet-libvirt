#
# libvirt::config
#
# @summary Installs configuration files
#
# @param qemu_hook
#   source name for qemu hook
# @param qemu_conf
#   configuration that goes into qemu.conf
# @param uri_aliases
#   uri alias from libvirt.conf
# @param uri_default
#   uri default from libvirt.conf
# @param default_conf
#   defaults for libvirtd.conf
# @param libvirtd_conf
#   libvirtd.conf configs
# @param config_dir
#   directory for configs
# 
# @note parameter are inherited from ::libvirt and documented there.
class libvirt::config (
  Optional[String]                                     $qemu_hook        = $libvirt::qemu_hook,
  Hash                                                 $qemu_conf        = $libvirt::qemu_conf,
  Array                                                $uri_aliases      = $libvirt::uri_aliases,
  Optional[String]                                     $uri_default      = $libvirt::uri_default,
  Hash                                                 $default_conf     = $libvirt::default_conf,
  Hash[Optional[String],Variant[String,Integer,Array]] $libvirtd_conf    = $libvirt::libvirtd_conf,
  String                                               $config_dir       = $libvirt::config_dir,
) inherits libvirt {
  if $qemu_hook {
    file { "${config_dir}/hooks/qemu":
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => "puppet:///modules/libvirt/hooks/qemu/${libvirt::qemu_hook}",
    }
  }

  if ($qemu_conf != {}) {
    file { "${config_dir}/qemu.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('libvirt/qemu.conf.erb'),
    }
  }

  if ( $uri_default != '' ) or ( $uri_aliases != []) {
    file { "${config_dir}/libvirt.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('libvirt/libvirt.conf.epp'),
    }
  }

  $default_conf.each | String $key, String $value | {
    libvirtd_default {
      $key: value => $value;
    }
  }

  $libvirtd_conf.each | String $key, Variant[String,Integer,Array] $value | {
    if $value =~ Array {
      libvirtd_conf { $key:
        value => join(['["', $value.join('","'), '"]']);
      }
    } else {
      libvirtd_conf { $key:
        value => $value,
      }
    }
  }
}
