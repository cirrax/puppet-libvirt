# == Class: libvirt::manage_domains_config
#
# Installs configuration files for manage-domains script
class libvirt::manage_domains_config {

  include libvirt::params

  concat { $libvirt::params::manage_domains_config:
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  concat::fragment { "${libvirt::params::manage_domains_config} header":
    target  => $libvirt::params::manage_domains_config,
    content => template('libvirt/manage-domains.ini.header.erb'),
    order   => '01',
  }
}
