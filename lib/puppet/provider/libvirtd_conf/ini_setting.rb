Puppet::Type.type(:libvirtd_conf).provide(
  :ini_setting,
  parent: Puppet::Type.type(:ini_setting).provider(:ruby),
) do

  def section
    ''
  end

  def setting
    resource[:name]
  end

  def separator
    ' = '
  end

  # hard code the file path (this allows purging)
  def self.file_path
    '/etc/libvirt/libvirtd.conf'
  end
end
