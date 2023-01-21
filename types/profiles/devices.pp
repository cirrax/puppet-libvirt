# A device of a Domain
type Libvirt::Profiles::Devices = Hash[
  String[1],  # profile name
  Variant[
    Struct[{
        'profileconfig' => Optional[Struct[{ 'base' => Optional[String[1]] }]],
    }],
    Libvirt::Domain::Device,
  ]
]
