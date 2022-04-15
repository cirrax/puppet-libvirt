
Puppet::Type.newtype(:libvirtd_conf) do
  ensurable

  newparam(:name, namevar: true) do
    desc 'setting name to manage value in libvirtd.conf'
    newvalues(%r{\S+})
  end

  newproperty(:value) do
    desc 'The value of the setting to be defined.'

    munge do |value|
      value = if value.is_a?(Integer)
                value.to_s.strip
              elsif %r{^\[.*\]$}.match?(value)
                value.to_s.strip
              elsif value.is_a?(String)
                '"' + value + '"'
              else
                value.to_s.strip
              end
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
