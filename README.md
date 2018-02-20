# libvirt puppet module

[![Build Status](https://travis-ci.org/cirrax/puppet-libvirt.svg?branch=master)](https://travis-ci.org/cirrax/puppet-libvirt)
[![Puppet Forge](https://img.shields.io/puppetforge/v/cirrax/libvirt.svg?style=flat-square)](https://forge.puppetlabs.com/cirrax/libvirt)
[![Puppet Forge](https://img.shields.io/puppetforge/dt/cirrax/libvirt.svg?style=flat-square)](https://forge.puppet.com/cirrax/libvirt)
[![Puppet Forge](https://img.shields.io/puppetforge/e/cirrax/libvirt.svg?style=flat-square)](https://forge.puppet.com/cirrax/libvirt)
[![Puppet Forge](https://img.shields.io/puppetforge/f/cirrax/libvirt.svg?style=flat-square)](https://forge.puppet.com/cirrax/libvirt)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#description)
3. [Usage - Configuration options and additional functionality](#usage)
3. [Reference](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Overview

Puppet module to install libvirt and create virtual domain
configuration. This module has very minimal external dependencies and
tries to not make any assumptions about how you want to setup your
virtual machines.

The module contains helper scripts to manage VMs on a 2 node cluster
with disk replication over DRBD. But this is completely optional.

## Description

This module tries to adhere to the Unix philosophy of doing one thing
but doing it right. It installs and configures libvirt and virtual
domains, but does not do the basic setup of your networking bridge or
configure the disks used by the virtual domains. This is left to other
puppet modules.

For a basic setup you have to include the `libvirt` class, define a
`libvirt::network` and a `libvirt::domain`.

As an optional add-on this module contains a libvirt hook and a
Python management script to create a 2 node cluster with disks
replicated over DRBD. This setup allows live migration of VMs from one
node to the other.

A complete working solution can be achived by integrating the following
modules in addition to this module:

* [puppetlabs-lvm](http://forge.puppetlabs.com/puppetlabs/lvm)
* [puppet-drbd](https://forge.puppet.com/puppet/drbd) (only
  for DRBD setups)
* [puppet-vswitch](https://forge.puppet.com/openstack/vswitch)
  (only when using OpenvSwitch)

## Usage

Install libvirt:

    class {'libvirt': }

Install including the DRBD hook:

    class {'libvirt':
      qemu_hook => 'drbd',
    }

Define a network (basic linux bridge example):

    libvirt::network { 'net-simple':
        forward_mode   => 'bridge',
        bridge         => 'br-simple',
    }

Define a network (advanced openvswitch example):

    libvirt::network { 'net-ovs':
      forward_mode     => 'bridge',
      bridge           => 'br-ovs',
      virtualport_type => 'openvswitch',
      autostart        => true,
      portgroups       => [
                           {'name'     => 'intern',
                            'trunk'    => false,
                            'vlan_tag' => '2',
                            },
                           {'name'     => 'trunk',
                            'trunk'    => true,
                            'vlan_tag' => ['100', '101', '102', ],
                            },
                           ],
    }

Define a domain (VM):

    libvirt::domain { 'my-domain':
      max_memory     => '2000',
      cpus           => 2,
      boot           => 'hd',
      disks          => [{'type' => 'block',
                          'device' => 'disk',
                          'source' => {'dev' => '/dev/vm-pool/my-domain.img'},
                          },
                         {'type'   => 'file',
                          'device' => 'disk',
                          'source' => {'dev' => '/var/lib/libvirt/images/my-disk.qcow2'},
                          'bus'    => 'virtio',
                          'driver' => {'name'  => 'qemu',
                                       'type'  => 'qcow2',
                                       'cache' => 'none',
                                       },
                         ],
      interfaces     => [{'network' => 'net-simple'},],
      autostart      => true,
    }

Configure libvirtd settings in libvirtd.conf file:

    class { '::libvirtd':
        libvirtd_conf => {
            'listen_tcp' => 1,
            'tcp_port'   => 16509,
        }
    }
Complete documentation is included in puppet doc format in the
manifest files.

## Reference
### Functions

#### libvirt_generate_mac
Returns a MAC address in the QEMU/KVM MAC OID (52:54:00:...)

#### libvirt_generate_mac_addresses
Generates MAC addresses for all interfaces in the array which do not yet have an
address specified. The MAC addresses are based on the domain name, network and
portgroup.

## Limitations

Things currently not supported:
* Operating Systems other than Debian or RedHat. Adding support for other
  systems is a matter of defining the relevant parameters in
  params.pp. So this is really easy for someone with access to such a
  system.
* libvirt storage pools
* Network interfaces not attached to a libvirt network

Patches to support any of these (or other) missing features are welcome.

## Contributing

Please report bugs and feature request using GitHub issue tracker.

For pull requests, it is very much appreciated to check your Puppet manifest with puppet-lint
and the available spec tests  in order to follow the recommended Puppet style guidelines
from the Puppet Labs style guide.
