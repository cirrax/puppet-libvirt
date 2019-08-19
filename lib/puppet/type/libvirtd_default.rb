
Puppet::Type.newtype(:libvirtd_default) do
  ensurable

  newparam(:name, namevar: true) do
    desc 'setting name to manage default for libvirtd'
    newvalues(%r{\S+})
  end

  newproperty(:value) do
    desc 'The value of the setting to be defined.'
    munge do |value|
      value = value.to_s.strip
      value
    end

    def is_to_s(currentvalue) # rubocop:disable Style/PredicateName
      if resource.secret?
        '[old secret redacted]'
      else
        currentvalue
      end
    end

    def should_to_s(newvalue)
      if resource.secret?
        '[new secret redacted]'
      else
        newvalue
      end
    end
  end

  newparam(:secret, boolean: true) do
    desc 'Whether to hide the value from Puppet logs. Defaults to `false`.'

    newvalues(:true, :false)

    defaultto false
  end

  autorequire(:class) { 'libvirt::install' }
end
