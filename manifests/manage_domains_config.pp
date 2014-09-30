# == Class: libvirt::manage_domains_config
#
# Installs configuration files for manage-domains script
class libvirt::manage_domains_config {
  concat { $params::manage_domains_config:
    owner => 'root',
    group => 'root',
    mode  => '644',
    force => false,
  }

  concat::fragment { "${params::manage_domains_config} header":
    target  => $params::manage_domains_config,
    content => template('libvirt/manage-domains.ini.header.erb'),
    order   => '01',
  }
}
