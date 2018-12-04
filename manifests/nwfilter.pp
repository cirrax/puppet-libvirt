define libvirt::nwfilter (
  $uuid              = libvirt_generate_uuid($name),
  $ip		     = undef,
  $publictcpservices = [],
  $publicudpservices = [],
  $customtcprules    = [],  # syntax: [{remote_ip => port}, ... ]
  $customudprules    = [],
) {

  include ::libvirt

  exec {"libvirt-nwfilter-${name}":
    command  => join(['f=$(mktemp) && echo "',
                      template('libvirt/nwfilter.xml.erb'),
                      '" > $f && virsh nwfilter-define $f && rm $f']),
    provider => 'shell',
    require  => Anchor['libvirt::end'],
  }
}
