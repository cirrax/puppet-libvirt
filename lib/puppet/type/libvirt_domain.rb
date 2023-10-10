# frozen_string_literal: true

require 'puppet/parameter/boolean'

Puppet::Type.newtype(:libvirt_domain) do
  @doc = 'ensures a persistent domain (vm) (transient domains are ignored)
         '
  ensurable

  newparam(:name, namevar: true) do
    desc 'name of the domain, name as namevar'

    validate do |value|
      raise ArgumentError, 'The name of the libvirt domain (vm) name needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:uuid) do
    desc 'uuid to use for creation of a new domain, if undef (default) automatic creation'
  end

  newparam(:show_diff, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "Whether to display whole change when the xml changes, defaulting to
        false, since we do not want to fill up logs !"
    defaultto :false
  end

  newparam(:replace, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "Set this to true to replace a already existing VM. To avoid change the VM
          pn every puppet run, you need to set the ignore parameter according your VM definition."
    defaultto :false
  end

  newparam(:ignore) do
    desc "Array of Xpath definitions to ignore. Libvirt generates some configurations automatic
          wich are shown in the xml output. This array defines Xpath queries of such configurations"
    defaultto []
    validate do |value|
      raise ArgumentError, 'ignore parameter needs to be an Array' unless value.is_a?(Array)
    end
  end

  newproperty(:active) do
    desc 'Whether the domain should be started (active=true), or shutdown (active=false)'
    newvalues(:true)
    newvalues(:false)
  end

  newproperty(:autostart) do
    desc 'Whether the domain should be autostarted.'
    defaultto(:false)
    newvalues(:true)
    newvalues(:false)
  end

  newproperty(:content) do
    desc 'content of the domain formated as XML'

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

  # autorequire Anchor['libvirt::installed']
  autorequire(:anchor) do
    ['libvirt::installed']
  end
end
