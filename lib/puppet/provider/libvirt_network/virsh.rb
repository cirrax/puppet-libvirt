# frozen_string_literal: true

#
# This file contains a provider for the resource type `libvirt_network`,
#
require 'tempfile'
require_relative '../../../puppet_x/libvirt/rexml_sorted_attributes.rb'
require_relative '../../../puppet_x/libvirt/sort_elements.rb'

Puppet::Type.type(:libvirt_network).provide(:virsh) do
  desc "@summary provider for the resource type `libvirt_network`,
        which manages a network on libvirt
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
    virsh('--quiet', 'net-define', tmpfile.path)
  ensure
    tmpfile.close
    tmpfile.unlink
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.instances
    virsh('--quiet', '--readonly', 'net-list', '--table', '--all', '--persistent').split("\n").map do |line|
      raise Puppet::Error, "Cannot parse invalid network line: #{line}" unless line =~ %r{^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)$}
      new(
        ensure: :present,
        name: Regexp.last_match(1),
        active: (Regexp.last_match(2) == 'active') ? :true : :false,
        autostart: (Regexp.last_match(3) == 'yes') ? :true : :false,
        uuid: virsh('--quiet', '--readonly', 'net-uuid', '--network', Regexp.last_match(1)),
      )
    end
  end

  def self.prefetch(resources)
    networks = instances
    resources.each_key do |name|
      if (provider = networks.find { |network| network.name == name })
        resources[name].provider = provider
      end
    end
  end

  def create
    virsh_define(resource[:content])
    @property_hash[:ensure] = :present

    should_active = @resource.should(:active)
    self.active = should_active unless active == should_active

    should_autostart = @resource.should(:autostart)
    self.autostart = should_autostart unless autostart == should_autostart
  end

  def destroy
    begin
      virsh('--quiet', 'net-destroy', @resource[:name])
    rescue
      # do nothing
    end
    virsh('--quiet', 'net-undefine', @resource[:name])
    @property_hash[:ensure] = :absent
  end

  def content=(_content)
    @property_flush[:content] = resource[:content]
  end

  def content
    return '' unless @property_hash[:ensure] == :present
    begin
      xml = REXML::Document.new(virsh('--quiet', '--readonly', 'net-dumpxml', @resource[:name]))
    rescue REXML::ParseException => msg
      raise Puppet::ParseError, "libvirt_network: cannot parse xml: #{msg}"
    end
    # remove the uuid
    xml.root.elements.delete('//uuid')
    # remove an existing mac address, we do not define it...
    xml.root.elements.delete('//mac')
    # remove the connections
    xml.root.attributes.delete('connections')
    xml.root.elements.each('//forward/interface[@connections]') do |el|
      el.attributes.delete('connections')
    end
    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    output = ''.dup
    formatter.write(recursive_sort(xml.root), output)
    output
  end

  def active
    @property_hash[:active] || :false
  end

  def active=(active)
    if active == :true
      virsh('--quiet', 'net-start', '--network', @resource[:name])
      @property_hash[:active] = 'true'
    else
      virsh('--quiet', 'net-destroy', '--network', @resource[:name])
      @property_hash[:active] = 'false'
    end
  end

  def autostart
    @property_hash[:autostart] || :false
  end

  def autostart=(autostart)
    if autostart == :true
      virsh('--quiet', 'net-autostart', '--network', @resource[:name])
      @property_hash[:autostart] = :true
    else
      virsh('--quiet', 'net-autostart', '--network', @resource[:name], '--disable')
      @property_hash[:autostart] = :false
    end
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
