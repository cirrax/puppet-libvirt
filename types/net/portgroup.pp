# network portgroup
type Libvirt::Net::Portgroup = Struct[{
    name                => String[1],
    trunk               => Optional[Boolean],                             # for simple template only
    vlan_tag            => Optional[Variant[String[1],Array[String[1]]]], # for simple template only
    vlan                => Optional[Libvirt::Net::Vlan],
    bandwith            => Optional[Libvirt::Net::Bandwith],
    virtualport         => Optional[Libvirt::Net::Virtualport],
    'default'           => Optional[Enum['yes']],
    trustGuestRxFilters => Optional[Enum['yes', 'no']],
}]
