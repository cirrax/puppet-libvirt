# network port
type Libvirt::Net::Port = Struct[{
    isolated => Optional[Enum['yes', 'no']],
}]
