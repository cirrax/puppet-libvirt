# Most of the code of this file comes from https://github.com/thias/puppet-libvirt/blob/master/lib/puppet/provider/libvirt_pool/virsh.rb
# Kudos to Thias for it :)
#
require 'rexml/document'
require 'tempfile'

Puppet::Type.type(:libvirt_pool).provide(:virsh) do
  commands virsh: 'virsh'

  def self.instances
    list = virsh('-q', 'pool-list', '--all')
    list.split(%r{\n})[0..-1].map do |line|
      values = line.strip.split(%r{ +})
      new(
        name: values[0],
        active: (values[1] =~ %r{^act}) ? :true : :false,
        autostart: (values[2] =~ %r{no}) ? :false : :true,
        provider: name,
      )
    end
  end

  def status
    list = virsh('-q', 'pool-list', '--all')
    list.split(%r{\n})[0..-1].find do |line|
      fields = line.strip.split(%r{ +})
      if fields[0] =~ %r{^#{resource[:name]}$}
        return :present
      end
    end
    :absent
  end

  def self.prefetch(resources)
    pools = instances
    resources.keys.each do |name|
      if provider == pools.find { |pool| pool.name == name }
        resources[name].provider = provider
      end
    end
  end

  def create
    defined = definepool

    # for some reason the pool has not been defined
    # malformed xml
    # or failed tmpfile creationa
    # or ?
    raise Puppet::Error, 'Unable to define the pool' unless defined

    buildpool

    @property_hash[:ensure] = :present
    should_active = @resource.should(:active)
    self.active = should_active unless active == should_active

    should_autostart = @resource.should(:autostart)
    self.autostart = should_autostart unless autostart == should_autostart
  end

  def destroy
    destroypool
    @property_hash.clear
  end

  def definepool
    result = false
    begin
      tmpfile = Tempfile.new("pool.#{resource[:name]}")
      xml = buildpoolxml resource
      tmpfile.write(xml)
      tmpfile.rewind
      virsh('pool-define', tmpfile.path)
      result = true
    ensure
      tmpfile.close
      tmpfile.unlink
    end
    result
  end

  def buildpool
    virsh('pool-build', '--pool', resource[:name])
  rescue
    # Unable to build the pool maybe because
    # it is already defined (it this case we should consider
    # to continue execution)
    # or there is permission issue on the fs
    # or ?
    # in these cases we should consider raising something
    notice('Unable to build the pool')
  end

  def destroypool
    begin
      virsh('pool-destroy', resource[:name])
    rescue Puppet::ExecutionFailure => e
      notice(e.message)
    end
    virsh('pool-undefine', resource[:name])
  end

  def active
    @property_hash[:active] || :false
  end

  def active=(active)
    if active == :true
      virsh 'pool-start', '--pool', resource[:name]
      @property_hash[:active] = 'true'
    else
      virsh 'pool-destroy', '--pool', resource[:name]
      @property_hash[:active] = 'false'
    end
  end

  def autostart
    @property_hash[:autostart] || :false
  end

  def autostart=(autostart)
    if autostart == :true
      virsh 'pool-autostart', '--pool', resource[:name]
      @property_hash[:autostart] = :true
    else
      virsh 'pool-autostart', '--pool', resource[:name], '--disable'
      @property_hash[:autostart] = :false
    end
  end

  def exists?
    @property_hash[:ensure] != :absent
  end

  def buildpoolxml(resource)
    root = REXML::Document.new
    pool = root.add_element 'pool', 'type' => resource[:type]
    name = pool.add_element 'name'
    name.add_text resource[:name]

    srchost = resource[:sourcehost]
    srcpath = resource[:sourcepath]
    srcdev = resource[:sourcedev]
    srcname = resource[:sourcename]
    srcformat = resource[:sourceformat]

    if srchost || srcpath || srcdev || srcname || srcformat
      source = pool.add_element 'source'

      source.add_element('host', 'name' => srchost)     if srchost
      source.add_element('dir', 'path' => srcpath)      if srcpath
      source.add_element('format', 'type' => srcformat) if srcformat

      if srcdev
        Array(srcdev).each do |dev|
          source.add_element('device', 'path' => dev)
        end
      end

      if srcname
        srcnameel = source.add_element 'name'
        srcnameel.add_text srcname
      end
    end

    target = resource[:target]
    targetowner = resource[:target_owner]
    targetgroup = resource[:target_group]
    targetmode = resource[:target_mode]
    if target
      targetel = pool.add_element 'target'
      targetpathel = targetel.add_element 'path'
      targetpathel.add_text target

      if targetowner || targetgroup || targetmode
        targetpermissionsel = targetel.add_element 'permissions'

        if targetowner
          targetpermissionsownerel = targetpermissionsel.add_element 'owner'
          targetpermissionsownerel.add_text targetowner.to_s
        end

        if targetgroup
          targetpermissionsgroupel = targetpermissionsel.add_element 'group'
          targetpermissionsgroupel.add_text targetgroup.to_s
        end

        if targetmode
          targetpermissionsmodeel = targetpermissionsel.add_element 'mode'
          targetpermissionsmodeel.add_text targetmode.to_s
        end
      end
    end

    root.to_s
  end # buildpoolxml
end
