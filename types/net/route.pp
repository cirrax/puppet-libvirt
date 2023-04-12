# network route: 
# static routes
type Libvirt::Net::Route = Struct[{
    family => Optional[Enum['ipv6']],
    address => String[1],
    gateway => String[1],
    netmask => Optional[String[1]],
    prefix => Optional[String[1]],
    metric => Optional[Integer],
}]
