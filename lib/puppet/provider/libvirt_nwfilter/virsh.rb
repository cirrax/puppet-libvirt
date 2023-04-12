# frozen_string_literal: true

#
# This file contains a provider for the resource type `libvirt_nwfilter`,
#
require 'tempfile'
require_relative '../../../puppet_x/libvirt/rexml_sorted_attributes.rb'
require_relative '../../../puppet_x/libvirt/sort_elements.rb'

Puppet::Type.type(:libvirt_nwfilter).provide(:virsh) do
  desc "@summary provider for the resource type `libvirt_nwfilter`,
        which manages a nwfilter on libvirt
        using the virsh command."

  commands virsh: 'virsh'

  def virsh_define(content)
    xml = REXML::Document.new(content)
    if @property_hash[:uuid]
      xml.root.add_element('uuid').add_text(@property_hash[:uuid])
    end
    tmpfile = Tempfile.new(@resource[:name])
    tmpfile.write(xml.to_s)
    tmpfile.rewind
    virsh('--quiet', 'nwfilter-define', tmpfile.path)
  ensure
    tmpfile.close
    tmpfile.unlink
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.instances
    virsh('--quiet', '--readonly', 'nwfilter-list').split("\n").map do |line|
      raise Puppet::Error, "Cannot parse invalid nwfilter line: #{line}" unless line =~ %r{^\s*(\S+)\s+(\S+)$}
      new(
        ensure: :present,
        name: Regexp.last_match(2),
        uuid: Regexp.last_match(1),
      )
    end
  end

  def self.prefetch(resources)
    nwfilters = instances
    resources.each_key do |name|
      if (provider = nwfilters.find { |nwfilter| nwfilter.name == name })
        resources[name].provider = provider
      end
    end
  end

  def create
    virsh_define(resource[:content])
    @property_hash[:ensure] = :present
  end

  def destroy
    virsh('--quiet', 'nwfilter-undefine', @resource[:name])
    @property_hash[:ensure] = :absent
  end

  def content=(_content)
    @property_flush[:content] = resource[:content]
  end

  def content
    return '' unless @property_hash[:ensure] == :present
    begin
      xml = REXML::Document.new(virsh('--quiet', '--readonly', 'nwfilter-dumpxml', @resource[:name]))
    rescue REXML::ParseException => msg
      raise Puppet::ParseError, "libvirt_nwfilter: cannot parse xml: #{msg}"
    end
    # remove the uuid
    xml.root.elements.delete('//uuid')
    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    output = ''.dup
    formatter.write(recursive_sort(xml.root), output)
    output
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def flush
    return if @property_flush.empty?
    content = @property_flush[:content] || @resource[:content]
    virsh_define(content)
    @property_flush.clear
  end
end
