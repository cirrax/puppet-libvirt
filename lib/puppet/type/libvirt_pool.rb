# Most of the code of this file comes from https://github.com/thias/puppet-libvirt/blob/master/lib/puppet/type/libvirt_pool.rb
# Kudos to Thias for it :)
#
Puppet::Type.newtype(:libvirt_pool) do
  @doc = "Manages libvirt pools

          @example
            libvirt_pool { 'default' :
              ensure => absent
            }

          @example
            libvirt_pool { 'mydirpool' :
              ensure    => present,
              active    => true,
              autostart => true,
              type      => 'dir',
              target    => '/tmp/mypool',
            }
          @example
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
          "

  ensurable do
    desc 'Manages the creation or the removal of a pool
    `present` means that the pool will be defined and created
    `absent` means that the pool will be purged from the system'

    defaultto(:present)
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      if provider.exists?
        provider.destroy
      end
    end

    def retrieve
      provider.status
    end
  end

  newparam(:name, namevar: true) do
    desc 'The pool name.'
    newvalues(%r{^\S+$})
  end

  newparam(:type) do
    desc 'The pool type.'
    newvalues(:dir, :netfs, :fs, :logical, :disk, :iscsi, :mpath, :rbd, :sheepdog)
  end

  newparam(:sourcehost) do
    desc 'The source host.'
    newvalues(%r{^\S+$})
  end

  newparam(:sourcepath) do
    desc 'The source path.'
    newvalues(%r{(\/)?(\w)})
  end

  newparam(:sourcedev) do
    desc 'The source device.'
    newvalues(%r{(\/)?(\w)})
  end

  newparam(:sourcename) do
    desc 'The source name.'
    newvalues(%r{^\S+$})
  end

  newparam(:sourceformat) do
    desc 'The source format.'
    newvalues(:auto, :nfs, :glusterfs, :cifs)
  end

  newparam(:target) do
    desc 'The target.'
    newvalues(%r{(\/)?(\w)})
  end

  newparam(:target_owner) do
    desc 'The owner of the target dir or filesystem'
    newvalues(%r{^\S+$})
  end

  newparam(:target_group) do
    desc 'The group of the target dir or filesystem'
    newvalues(%r{^\S+$})
  end

  newparam(:target_mode) do
    desc 'The mode of the target dir or filesystem'
    newvalues(%r{^[0-7]{4}$})
  end

  newproperty(:active) do
    desc 'Whether the pool should be started.'
    defaultto(:true)
    newvalues(:true)
    newvalues(:false)
  end

  newproperty(:autostart) do
    desc 'Whether the pool should be autostarted.'
    defaultto(:false)
    newvalues(:true)
    newvalues(:false)
  end

  validate do
    # https://libvirt.org/formatstorage.html#StoragePoolTarget
    if (self[:target_owner] || self[:target_group] || self[:target_mode]) && ![:fs, :dir].include?(self[:type])
      Puppet.warning('target_(owner|group|mode) is currently only useful for directory or filesystem based pools')
    end
  end
end
