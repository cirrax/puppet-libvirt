# a single nwfilter rule
type Libvirt::Nwfilter::Rule = Struct[{
    action     => Enum['drop','reject','accept','return','continue'],
    direction  => Enum['in','out','inout'],
    priority   => Optional[Libvirt::Nwfilter::Priority],
    statematch => Optional[Enum['0','false','1','true']],
    protocols  => Optional[Array[Optional[Variant[
            Libvirt::Nwfilter::Protocol::Mac,
            Libvirt::Nwfilter::Protocol::Vlan,
            Libvirt::Nwfilter::Protocol::Stp,
            Libvirt::Nwfilter::Protocol::Arp_rarp,
            Libvirt::Nwfilter::Protocol::Ipv4,
            Libvirt::Nwfilter::Protocol::Ipv6,
            Libvirt::Nwfilter::Protocol::Tcp_udp_sctp,
            Libvirt::Nwfilter::Protocol::Icmp,
            Libvirt::Nwfilter::Protocol::Igmp_esp_ah_udplite_all,
            Libvirt::Nwfilter::Protocol::Tcpipv6_udpipv6_sctpipv6,
            Libvirt::Nwfilter::Protocol::Icmpv6,
            Libvirt::Nwfilter::Protocol::Espipv6_ahipv6_udpliteipv6_allipv6,
    ]]]]
}]
