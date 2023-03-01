# nwfilter rule protocol of mac
type Libvirt::Nwfilter::Protocol::Mac = Struct[{
    id         => Enum['mac'],
    match      => Optional[Enum['no','yes']],
    srcmacaddr => Optional[String[1]],
    srcmacmask => Optional[String[1]],
    dstmacaddr => Optional[String[1]],
    dstmacmask => Optional[String[1]],
    protocolid => Optional[Variant[
        Enum['arp', 'rarp', 'ipv4', 'ipv6'],
        Pattern[/\A0x[0-9]{1,4}\Z/],
    ]],
    comment    => Optional[String[1,256]],
    connlimit-above => Optional[Integer],
}]
