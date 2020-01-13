Puppet::Type.type(:libvirtd_default).provide(
  :ini_setting,
  parent: Puppet::Type.type(:ini_setting).provider(:ruby),
) do
  desc '
    @summary add config to /etc/default/libvirtd
  '

  def section
    ''
  end

  def setting
    resource[:name]
  end

  def separator
    '='
  end

  def self.file_path
    if Facter.value(:osfamily) == 'RedHat'
      '/etc/sysconfig/libvirtd'
    else
      '/etc/default/libvirtd'
    end
  end

  # this needs to be removed. This has been replaced with the class method
  def file_path
    self.class.file_path
  end
end
