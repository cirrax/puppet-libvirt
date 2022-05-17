# network dns
type Libvirt::Net::Dns = Struct[{
    enable => Optional[Enum['yes','no']],
    forwardPlainNames => Optional[Enum['yes','no']],
    forwarder => Optional[Array[Struct[{
            addr => Optional[String[1]],
            domain => Optional[String[1]],
    }]]],
    txt => Optional[Array[Struct[{
            name => Optional[String[1]],
            value => Optional[String[1]],
    }]]],
    srv => Optional[Array[Struct[{
            service => String[1],
            protocol => String[1],
            domain => Optional[String[1]],
            target => Optional[String[1]],
            port => Optional[Integer],
            priority => Optional[Integer],
            weight => Optional[Integer],
    }]]],
    host => Optional[Array[Struct[{
            ip => String[1],
            hostname => Array[String[1]],
    }]]],
}]
