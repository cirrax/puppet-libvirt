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
#
# find some default profiles in the data/profiles directory 
#
class libvirt::profiles (
  Hash $devices,
  Hash $domconf,
) {
}
