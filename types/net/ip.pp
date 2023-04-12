# network ip: 
# The IP element sets up NAT'ing and an optional DHCP server local to the host.
type Libvirt::Net::IP = Struct[{
    address => Optional[String[1]],
    netmask => Optional[String[1]],
    prefix => Optional[String[1]],
    family => Optional[String[1]],
    localPtr => Optional[String[1]],
    tftp    => Optional[Array[Struct[{
            root => String[1],
    }]]],
    dhcp => Optional[Struct[{
          range => Optional[Array[Struct[{
                  start => String[1],
                  end   => String[1],
                  lease => Optional[Array[Struct[{
                          expiry => Integer,
                          unit   => Optional[Enum['seconds', 'minutes', 'hours']],
                  }]]],
                  unit   => Optional[String[1]],
          }]]],
          host => Optional[Array[Struct[{
                  mac => Optional[String[1]],
                  id => Optional[String[1]],
                  name => Optional[String[1]],
                  ip => String[1],
                  lease => Optional[Array[Struct[{
                          expiry => Integer,
                          unit   => Optional[Enum['seconds', 'minutes', 'hours']],
                  }]]],
          }]]],
          bootp => Optional[Struct[{
                file => Optional[String[1]],
                server => Optional[String[1]],
          }]],
    }]],
}]
