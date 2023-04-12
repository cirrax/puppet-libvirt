# network metadata
type Libvirt::Net::Bandwith = Struct[{
    inbound  => Optional[Struct[{
          average => Optional[Integer],
          peak    => Optional[Integer],
          burst   => Optional[Integer],
          floot   => Optional[Integer],
    }]],
    outbound => Optional[Struct[{
          average => Optional[Integer],
          peak    => Optional[Integer],
          burst   => Optional[Integer],
    }]],
}]
