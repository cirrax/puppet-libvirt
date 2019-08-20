# libvirt::profiles
#
# @summary this class loads all the available profiles for usage in domain.pp
#
# @param devices
#   devices profiles to load
# @param domconf
#   domconf profiles to load
#
class libvirt::profiles (
  Hash $devices,
  Hash $domconf,
) {
}
