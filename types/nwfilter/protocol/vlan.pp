# nwfilter rule protocol of VLAN
type Libvirt::Nwfilter::Protocol::Vlan = Struct[{
    id             => Enum['vlan'],
    match          => Optional[Enum['no','yes']],
    srcmacaddr     => Optional[String[1]],
    srcmacmask     => Optional[String[1]],
    dstmacaddr     => Optional[String[1]],
    dstmacmask     => Optional[String[1]],
    vlanid         => Optional[Integer[0,4095]],
    encap_protocol => Optional[Variant[
        Enum['arp','ipv4','ipv6'],
        Integer[0,65535]
    ]],
    comment        => Optional[String[1,256]],
    connlimit-above => Optional[Integer],
}]
