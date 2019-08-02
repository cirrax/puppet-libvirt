# == Class: libvirt::profiles
#
# this class loads all the available profiles for usage in domain.pp
#
#
# === Parameters
#
# [*devices*]
#   devices profiles to load
# [*domconf*]
#   domconf profiles to load
#
class libvirt::profiles (
  Hash $devices,
  Hash $domconf,
) {
}
