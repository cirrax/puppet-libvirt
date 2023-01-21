# libvirt::profiles
#
# @summary this class loads all the available profiles for usage in domain.pp
#
# @param devices
#   devices profiles to load
#   remark: parameter is hiera hash merged
# @param domconf
#   domconf profiles to load
#   remark: parameter is hiera hash merged
# @param ignore
#   an Array per profile of Xpath definitions to ignore when comparing the
#   configured with the persistent/running configuration of a domain.
#   Libvirt add some default configurations which should not be included
#   in the XML we compare.
#   remark: parameter is hiera hash merged
#
# find some default profiles in the data/profiles directory 
#
class libvirt::profiles (
  Libvirt::Profiles::Devices        $devices,
  Hash                              $domconf,
  Hash[String[1], Array[String[1]]] $ignore = {},
) {
}
