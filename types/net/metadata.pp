# network metadata
type Libvirt::Net::Metadata = Struct[{
    ipv6                => Optional[Enum['yes','no']],
    trustGuestRxFilters => Optional[Enum['yes','no']],
}]
