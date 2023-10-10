# frozen_string_literal: true

require 'puppet/parameter/boolean'


Puppet::Type.newtype(:libvirt_network) do
  @doc = 'ensures a persistent network (transient networks are ignored)
         '
  ensurable

  newparam(:name, namevar: true) do
    desc 'name of the network, name as namevar'

    validate do |value|
      raise ArgumentError, 'The name of the libvirt network name needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:uuid) do
    desc 'uuid to use for creation of a new network, if undef (default) automatic creation'
  end

  newparam(:show_diff, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "Whether to display whole change when the xml changes, defaulting to
        false, since we do not want to fill up logs !"
    defaultto :false
  end

  newproperty(:active) do
    desc 'Whether the network should be started. (active)'
    defaultto(:true)
    newvalues(:true)
    newvalues(:false)
  end

  newproperty(:autostart) do
    desc 'Whether the network should be autostarted.'
    defaultto(:true)
    newvalues(:true)
    newvalues(:false)
  end

  newproperty(:content) do
    desc 'content of the network formated as XML'

    validate do |value|
      raise ArgumentError, 'content needs to be a XML string' unless value.is_a?(String)
    end

    def should_to_s(value)
      if @resource[:show_diff]
        ":\n" + value + "\n"
      else
        '{md5}' + Digest::MD5.hexdigest(value.to_s)
      end
    end

    def is_to_s(value) # rubocop:disable Naming/PredicateName
      if @resource[:show_diff]
        ":\n" + value + "\n"
      else
        '{md5}' + Digest::MD5.hexdigest(value.to_s)
      end
    end
  end
end
