# A interface of a Domain
type Libvirt::Domain::Interface = Struct[{
    type           => Optional[String[1]],
    interface_type => Optional[Enum['network','bridge', 'vdpa', 'mcast', 'server', 'client', 'null', 'vds']],
    network        => Optional[String[1]],  # deprecated, do not use
    source         => Optional[Hash[String[1],String[1]]],
    portgroup      => Optional[String[1]],  # deprecated, do not use, use source hash instead
    address        => Optional[Hash[String[1],String[1]]],
    mac            => Optional[String[1]],
    filter         => Optional[Variant[
        String[1],
        Struct[{
            filterref  => String[1],
            parameters => Optional[Hash[
                String[1],
                Variant[String[1],Array[String[1]]]
            ]],
        }],
    ]],
    boot_order     => Optional[Integer],
}]
