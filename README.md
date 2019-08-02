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
Certain profiles can be defined and used for a set of VM's

The module contains helper scripts to manage VMs on a 2 node cluster
with disk replication over DRBD. But this is completely optional.

Remark: For puppet 3 support use versions 2.x.x !

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

If you want to see the diffs of the xml file generated, set libvirt::diff_dir to a 
directory. As a result all generated XML files are stored there, and diffs are
visible.

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

Define a storage pool:

    libvirt_pool { 'default' :
		ensure     => present,
		type       => 'logical',
		autostart  => true,
		sourcedev  => '/dev/sda5',
		sourcename => 'vm',
		target     => '/dev/vm',
    }

Complete documentation is included in puppet doc format in the
manifest files.

## Reference
### Profiles
Profiles are a set of values to add to the configuration, eg. some devices you like to add
to all VM's (keyboard etc.)

The default profile used is defined in hiera in the data/profiles directory.
The profiles in hiera are hash merged, so you can define you're own profiles easily.
Here is an example:

    libvirt::profiles::devices:
      myprofile:
        hostdev:
          attrs:
            mode: 'capabilities'
            type: 'misc'
          values:
            source:
               values: '/dev/input/event3'

will result in a device (without the default devices...):
    <hostdev mode='capabilities' type='misc'>
      <source>
        <char>/dev/input/event3</char>
      </source>
    </hostdev>

To not repeat all profile values you can 'inherit' a profile, meaning you set a base profile with wich the profile will be merged.
Let's take enlarge our profile:

    libvirt::profiles::devices:
      myprofile:
        profileconfig:
          base: 'default'
          merge: 'merge'
        hostdev:
          ...

which results in the hostdev been added to the default profile. Merge parameter in profileconfig defines how to merge,
valid values are merge (default) or deep for a deep merge.

Hint: To better see what is changing you can set libvirt::diff_dir to a directory.

### Functions

#### libvirt_generate_mac
Returns a MAC address in the QEMU/KVM MAC OID (52:54:00:...)

#### libvirt_generate_mac_addresses
Generates MAC addresses for all interfaces in the array which do not yet have an
address specified. The MAC addresses are based on the domain name, network and
portgroup.

#### libvirt_generate_uuid
Return a uuid for a VM.

#### libvirt::get_merged_profile
Returns the merged profile accoring to definition. The profileconfig section is removed.

### Types

#### libvirt_pool

Manages libvirt pools

Example :
  libvirt_pool { 'default' :
    ensure => absent
  }

  libvirt_pool { 'mydirpool' :
    ensure    => present,
    active    => true,
    autostart => true,
    type      => 'dir',
    target    => '/tmp/mypool',
  }

  libvirt_pool { 'mydirpool2' :
    ensure       => present,
    active       => true,
    autostart    => true,
    type         => 'dir',
    target       => '/tmp/mypool2',
    target_owner => 107,
    target_group => 107,
    target_mode  => '0755',
  }

  libvirt_pool { 'vm_storage':
    ensure    => 'present',
    active    => 'true',
    type      => 'logical',
    sourcedev => ['/dev/sdb', '/dev/sdc'],
    target    => '/dev/vg0'
  }


##### Properties

The following properties are available in the `libvirt_pool` type.

###### `ensure`

Valid values: present, absent

Manages the creation or the removal of a pool
`present` means that the pool will be defined and created
`absent` means that the pool will be purged from the system

Default value: present

###### `active`

Valid values: `true`, `false`

Whether the pool should be started.

Default value: true

###### `autostart`

Valid values: `true`, `false`

Whether the pool should be autostarted.

Default value: false

##### Parameters

The following parameters are available in the `libvirt_pool` type.

###### `name`

Valid values: /^\S+$/

namevar

The pool name.

###### `type`

Valid values: dir, netfs, fs, logical, disk, iscsi, mpath, rbd, sheepdog

The pool type.

###### `sourcehost`

Valid values: /^\S+$/

The source host.

###### `sourcepath`

Valid values: /(\/)?(\w)/

The source path.

###### `sourcedev`

Valid values: /(\/)?(\w)/

The source device.

###### `sourcename`

Valid values: /^\S+$/

The source name.

###### `sourceformat`

Valid values: auto, nfs, glusterfs, cifs

The source format.

###### `target`

Valid values: /(\/)?(\w)/

The target.

###### `target_owner`

Valid values: /^\S+$/

The owner of the target dir or filesystem

###### `target_group`

Valid values: /^\S+$/

The group of the target dir or filesystem

###### `target_mode`

Valid values: /^[0-7]{4}$/

The mode of the target dir or filesystem

## Limitations

Things currently not supported:
* Operating Systems other than Debian, Ubuntu or RedHat. Adding support for other
  systems is a matter of defining the relevant parameters in
  params.pp. So this is really easy for someone with access to such a
  system.
* Network interfaces not attached to a libvirt network

Patches to support any of these (or other) missing features are welcome.

## Contributing

Please report bugs and feature request using GitHub issue tracker.

For pull requests, it is very much appreciated to check your Puppet manifest with puppet-lint
and the available spec tests  in order to follow the recommended Puppet style guidelines
from the Puppet Labs style guide.
