# a nwfilter chain
type Libvirt::Nwfilter::Chain = Variant[
  Enum['root','mac','stp','vlan','arp','rarp','ipv4','ipv6'],
  Pattern[/\Amac-.+\Z/,/\Astp-.+\Z/,/\Avlan-.+\Z/,/\Ar*arp-.+\Z/,/\Aipv[46]-.+\Z/]
]
