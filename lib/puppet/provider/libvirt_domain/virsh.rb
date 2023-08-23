# frozen_string_literal: true

#
# This file contains a provider for the resource type `libvirt_domain`,
#
require 'tempfile'
require_relative '../../../puppet_x/libvirt/rexml_sorted_attributes.rb'
require_relative '../../../puppet_x/libvirt/sort_elements.rb'

Puppet::Type.type(:libvirt_domain).provide(:virsh) do
  desc "@summary provider for the resource type `libvirt_domain`,
        which manages a domains (VM's) on libvirt
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
    virsh('--quiet', 'define', tmpfile.path)
  ensure
    tmpfile.close
    tmpfile.unlink
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.instances
    # for autostart, we need to run virsh twice !
    virshlines = virsh('--quiet', '--readonly', 'list', '--table', '--all', '--persistent', '--no-autostart').gsub("\n", " no-autostart\n")
    virshlines << virsh('--quiet', '--readonly', 'list', '--table', '--all', '--persistent', '--autostart').gsub("\n", " autostart\n")
    virshlines.split("\n").map do |line|
      raise Puppet::Error, "Cannot parse invalid network line: #{line}" unless line =~ %r{^\s*(\S+)\s+(\S+)\s+(\w.*)\s+(\S+)$}
      new(
        ensure: :present,
        name: Regexp.last_match(2),
        active: (Regexp.last_match(1) == '-') ? :false : :true, # only active domains have a number
        autostart: (Regexp.last_match(4) == 'autostart') ? :true : :false,
      )
    end
  end

  def self.prefetch(resources)
    domains = instances
    resources.each_key do |name|
      if (provider = domains.find { |domain| domain.name == name })
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
      virsh('--quiet', 'destroy', @resource[:name])
    rescue
      # do nothing
    end

    virsh('--quiet', 'undefine', @resource[:name])
    @property_hash[:ensure] = :absent
  end

  def content=(_content)
    @property_flush[:content] = resource[:content]
  end

  def content
    return '' unless @property_hash[:ensure] == :present
    return @resource[:content] unless @resource[:replace]
    begin
      xml = REXML::Document.new(virsh('--quiet', '--readonly', 'dumpxml', @resource[:name]))
    rescue REXML::ParseException => msg
      raise Puppet::ParseError, "libvirt_domain: cannot parse xml: #{msg}"
    end
    # remove the elements to ignore
    @resource[:ignore].each do |rem|
      REXML::XPath.match(xml, rem).each(&:remove)
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
    # do nothing if undef !
    if active == :false
      virsh('--quiet', 'shutdown', '--domain', @resource[:name])
      @property_hash[:active] = :false
    elsif active == :true
      virsh('--quiet', 'start', '--domain', @resource[:name])
      @property_hash[:active] = :true
    end
  end

  def autostart
    @property_hash[:autostart] || :false
  end

  def autostart=(autostart)
    if autostart == :true
      virsh('--quiet', 'autostart', '--domain', @resource[:name])
      @property_hash[:autostart] = :true
    else
      virsh('--quiet', 'autostart', '--domain', @resource[:name], '--disable')
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
