# network domain
type Libvirt::Net::Domain = Struct[{
    name                => String[1],
    localOnly           => Optional[Enum['yes','no']],
}]
