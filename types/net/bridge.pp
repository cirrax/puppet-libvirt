# network bridge
type Libvirt::Net::Bridge = Variant[
  String[1],
  Struct[{
      name            => String[1],
      stp             => Optional[Enum['on','off']],
      delay           => Optional[Integer],
      macTableManager => Optional[Enum['kernel','libvirt']],
      zone            => Optional[String[1]],
  }]
]
