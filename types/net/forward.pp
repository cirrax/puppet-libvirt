# network forward
type Libvirt::Net::Forward = Struct[{
    mode => Enum['nat','route','open','bridge','private','vepa','passthrough','hostdev'],
    managed => Optional[Enum['yes','no']],
    dev  => Optional[String[1]],
    nat  => Optional[Struct[{
          addresses => Optional[Array[Struct[{
                  start => String[1],
                  end   => String[1],
          }]]],
          port => Optional[Struct[{
                start => Integer,
                end   => Integer,
          }]],
          ipv6 => Optional[Enum['yes']],
    }]],
    interface => Optional[Array[Struct[{
            dev => String[1],
    }]]],
    pf => Optional[Struct[{
          dev => String[1],
    }]],
    driver    => Optional[Struct[{
          name => Enum['vfio','kvm'],
    }]],
    address => Optional[Array[Struct[{
            type     => Optional[String[1]],
            domain   => Optional[String[1]],
            bus      => Optional[String[1]],
            slot     => Optional[String[1]],
            function => Optional[String[1]],
    }]]],
}]
