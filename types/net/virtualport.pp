# network virtualport
type Libvirt::Net::Virtualport = Struct[{
    type => Optional[Enum['802.1Qbg', 'openvswitch']],
    parameters => Optional[Array[Struct[{
            interfaceid => Optional[String[1]],
            managerid => Optional[Integer],
            typeid    => Optional[Integer],
            typeidversion => Optional[Integer],
            instanceid => Optional[String[1]],
            profileid => Optional[String[1]],
    }]]],
}]
