Puppet::Type.type(:libvirtd_default).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:libvirtd_default).provider(:ini_setting)
) do

  confine    :osfamily => :redhat
  defaultfor :osfamily => :redhat

  def self.file_path
    '/etc/sysconfig/libvirtd'
  end

end

