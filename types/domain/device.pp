# A device of a Domain
type Libvirt::Domain::Device = Variant[
  Array[Libvirt::Domain::Device],
  String[1],
  Integer,
  Struct[{
      values => Optional[Variant[Hash, String[1],Integer, Libvirt::Domain::Device]],
      attrs  => Optional[Variant[String[1], Integer, Hash]],
  }],
  Hash[String[1], Libvirt::Domain::Device],
]
