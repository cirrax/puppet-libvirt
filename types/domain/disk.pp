# A disk of a Domain
type Libvirt::Domain::Disk = Struct[{
    type       => Enum['file', 'block', 'network', 'volume'],
    device     => Enum['floppy', 'disk', 'cdrom', 'lun'],
    bus        => String[1],
    driver     => Optional[Hash[String[1],String[1]]],
    boot_order => Optional[Integer],
    source     => Optional[Hash[String[1], String[1]]],
}]
