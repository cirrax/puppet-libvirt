# libvirt puppet module

[![PDK](https://github.com/cirrax/puppet-libvirt/actions/workflows/pdk.yml/badge.svg)](https://github.com/cirrax/puppet-libvirt/actions/workflows/pdk.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/cirrax/libvirt.svg?style=flat-square)](https://forge.puppetlabs.com/cirrax/libvirt)
[![Puppet Forge](https://img.shields.io/puppetforge/dt/cirrax/libvirt.svg?style=flat-square)](https://forge.puppet.com/cirrax/libvirt)
[![Puppet Forge](https://img.shields.io/puppetforge/e/cirrax/libvirt.svg?style=flat-square)](https://forge.puppet.com/cirrax/libvirt)
[![Puppet Forge](https://img.shields.io/puppetforge/f/cirrax/libvirt.svg?style=flat-square)](https://forge.puppet.com/cirrax/libvirt)

#### Table of Contents

1. [Overview](#overview)
1. [Description](#description)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Profiles](#profiles)
1. [Limitations](#limitations)
1. [Contributing](#contributing)

## Upgrade warnings

Upgrading to puppet 8 comes with Ruby 3, which doesn't have the `rexml` gem bundled.
It should be [installed on the puppetserver](https://www.puppet.com/docs/puppet/7/server/gems.html#installing-and-removing-gems).

```bash
sudo puppetserver gem install rexml
```

Upgrade to version 5.x.x introduced types/providers for network, nwfilter and domains
replacing the execs used before version 5.0.0. To compare the XML's generated with puppet and
the actual running XML's generated with virsh they are sorted which leads to display lots of
changes if you use the diff_dir functionality.

Version 5.0.0 also introduce a generic template for network and nwfilter which should be more flexible
to define the configurations needed (the 'old' templates are still default).

Upgrade to version 4.x.x will probably break any existing setup (puppet run fails),
since several parameters of libvirt::domain are now deprecated in favor of using
profiles. To make upgrade easier (and see what happens), upgrade to version 3.1.x and
set libvirt::diff_dir. Like this you can see the changes to be applied after the upgrade.

## Overview

Puppet module to install libvirt and create virtual domain
configuration. This module has very minimal external dependencies and
tries to not make any assumptions about how you want to setup your
virtual machines.
Certain profiles can be defined and used for a set of VM's

The module contains helper scripts to manage VMs on a 2 node cluster
with disk replication over DRBD. But this is completely optional.

Remark: Debian >= 12 (bullseye) and Ubuntu >= 21.10 uses architecture
        specific packages. Currently amd64 is configured. Merge requests
        for other architectures are welcome!

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

```puppet
include 'libvirt'
```

Install including the DRBD hook:

```puppet
class {'libvirt':
  qemu_hook => 'drbd',
}
```

If you want to see the diffs of the xml file generated, set libvirt::diff_dir to a
directory. As a result all generated XML files are stored there, and diffs are
visible.

Define a network (basic linux bridge example):

```puppet
libvirt::network { 'net-simple':
  forward_mode => 'bridge',
  bridge       => 'br-simple',
}
```

Define a network (advanced openvswitch example):

```puppet
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
```

Define a domain (VM):

```puppet
libvirt::domain { 'my-domain':
  devices_profile => 'default',
  dom_profile     => 'default',
  boot            => 'hd',
  domconf         => { memory => { values => '2048', attrs => { unit => 'MiB' }}},
  disks           => [{'type' => 'block',
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
  interfaces      => [{'source' => {'network' => 'net-simple'}}],
  autostart       => true,
}
```
	
Define a domain (VM) with a bridged network:
*the network device must exist*
```
    libvirt::domain { 'my-domain':
      devices_profile => 'default',
      dom_profile     => 'default',
      boot            => 'hd',
      domconf         => { memory => { values => '2048', attrs => { unit => 'MiB' }}},
      disks           => [{'type' => 'block',
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
      interfaces      => [{ 'interface_type => 'bridge',
                            'source'        => { 'bridge' => virbr0', },
		         }],
      autostart       => true,
    }
```

Define a storage pool:

```puppet
libvirt_pool { 'default' :
  ensure     => present,
  type       => 'logical',
  autostart  => true,
  sourcedev  => '/dev/sda5',
  sourcename => 'vm',
  target     => '/dev/vm',
}
```

Complete documentation is included in puppet doc format in the
manifest files or in the REFERENCE.md file.

## Reference

The detailed configuration of all parameters is found in the REFERENCE.md file generated from
the strings in the manifests.

## Profiles

Profiles are a set of values to add to the configuration, eg. some devices you like to add
to all VM's (keyboard etc.)

The default profile used is defined in hiera in the data/profiles directory.
The profiles in hiera are hash merged, so you can define you're own profiles easily.
Here is an example:

```yaml
libvirt::profiles::devices:
  myprofile:
    hostdev:
      attrs:
        mode: 'capabilities'
        type: 'misc'
      values:
        source:
           values: '/dev/input/event3'
```

will result in a device (without the default devices...):

```xml
<hostdev mode='capabilities' type='misc'>
  <source>
    <char>/dev/input/event3</char>
  </source>
</hostdev>
```

To not repeat all profile values you can 'inherit' a profile, meaning you set a base profile with wich the profile will be merged.
Let's take enlarge our profile:

```yaml
---
libvirt::profiles::devices:
  myprofile:
    profileconfig:
      base: 'default'
      merge: 'merge'
    hostdev:
      ...
```

which results in the hostdev been added to the default profile. Merge parameter in profileconfig defines how to merge,
valid values are merge (default) or deep for a deep merge.

Hint: To better see what is changing you can set libvirt::diff_dir to a directory.

## Limitations

Things currently not supported:

* Operating Systems other than Debian, Ubuntu or RedHat. Adding support for other
  systems is a matter of defining the relevant parameters in hiera.
* Documentation always needs some love ;) I would especially appreciate some examples of
  profiles you are using.

Patches to support any of these (or other) missing features are welcome.

## Contributing

Please report bugs and feature request using GitHub issue tracker.

For pull requests, it is very much appreciated to check your Puppet manifest with puppet-lint
and the available spec tests  in order to follow the recommended Puppet style guidelines
from the Puppet Labs style guide.

### Authors

This module is mainly written by [Cirrax GmbH](https://cirrax.com).

See the [list of contributors](https://github.com/cirrax/puppet-libvirt/graphs/contributors)
for a list of all contributors.
