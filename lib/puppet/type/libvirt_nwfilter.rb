# frozen_string_literal: true

require 'puppet/parameter/boolean'

Puppet::Type.newtype(:libvirt_nwfilter) do
  @doc = 'ensures a nwfilter
         '
  ensurable

  newparam(:name, namevar: true) do
    desc 'name of the filter, name as namevar'

    validate do |value|
      raise ArgumentError, 'The name of the libvirt filter name needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:uuid) do
    desc 'uuid to use for creation of a new nwfilter, if undef (default) automatic creation'
  end

  newparam(:show_diff, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "Whether to display whole change when the xml changes, defaulting to
        false, since we do not want to fill up logs !"
    defaultto :false
  end

  newproperty(:content) do
    desc 'content of the nwfilter formated as XML'

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
