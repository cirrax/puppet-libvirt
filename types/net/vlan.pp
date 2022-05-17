# network vlan
type Libvirt::Net::Vlan = Struct[{
    trunk => Optional[Enum['yes']],
    tag => Array[Struct[{
          id         => Integer,
          nativeMode => Optional[Enum['untagged', 'tagged']],
    }]],
}]
