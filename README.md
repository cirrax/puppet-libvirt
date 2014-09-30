# libvirt

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#description)
3. [Usage - Configuration options and additional functionality](#usage)
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

A complete working solution ca be achived by integrating the following
modules in addition to this module:

* [puppetlabs-lvm](http://forge.puppetlabs.com/puppetlabs/lvm)
* [puppetlabs-drbd](http://forge.puppetlabs.com/puppetlabs/drbd) (only
  for DRBD setups)
* [puppet-vswitch](http://forge.puppetlabs.com/puppetlabs/vswitch)
  (only when using OpenvSwitch

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
                         ],
      interfaces     => [{'network' => 'net-simple'},],
      autostart      => true,
    }

Complete documentation is included in puppet doc format in the
manifest files.

## Limitations

Things currently not supported:
* Operating Systems other than Debian. Adding support for other
  systems is a matter of defining the relevant parameters in
  params.pp. So this is really easy for someone with access to such a
  system.
* libvirt storage pools
* Network interfaces not attached to a libvirt network

Patches to support any of these (or other) missing features are welcome.

## Development

Contributions are welcome. Please send pull request or patches to
gaudenz.steinlin@cirrax.com.

Browse source code:
http://git.cirrax.com/?p=puppet-modules/libvirt.git

Clone repository:
    git clone git://git.cirrax.com/puppet-modules/libvirt.git
