Puppet::Type.type(:libvirtd_default).provide(
  :redhat,
  parent: Puppet::Type.type(:libvirtd_default).provider(:ini_setting),
) do
  desc '
    @summary add config to /etc/sysconfig/libvirtd (for redhat family)
  '

  confine    osfamily: :redhat
  defaultfor osfamily: :redhat

  def self.file_path
    '/etc/sysconfig/libvirtd'
  end
end
