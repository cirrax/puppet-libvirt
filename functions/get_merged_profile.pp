#
# function to merge profiles.
#
# @summary
#   merges profiles
#
# A profile is a hash of values. A profile can depend on another profile.
# The base for a profile can be configured in the profiles data:
# $data['profileconfig']['base'], which should reference another profile.
# Merging is per default done using a hash merge. Alternativ deep_merge can 
# configured for a profile by setting $data['profileconfig']['merge'] to 'deep'.
# (remark: this is NOT the deep_merge of hiera, but of puppetlab-stdlib,
# see https://github.com/puppetlabs/puppetlabs-stdlib/blob/master/REFERENCE.md#deep_merge)
#
# @note 
#   The profiles are computed using recursion.
#   $data['profileconfig'] is removed from the resulting hash.
# @param profile_hash
#   all the profiles 
# @param profile
#   Name of the computed profile to return
# @return
#   the computed profile
# 
function libvirt::get_merged_profile(
  Hash   $profile_hash,
  String $profile,
) {
  $base_profile=pick($profile_hash[$profile].dig('profileconfig','base'), $profile)

  if $base_profile == $profile {
    # end of recursion, base is myself.
    $result=pick($profile_hash[$profile], {})
  } else {
    # recurse, to get the base profile to merge
    case pick($profile_hash.dig('profileconfig','merge'), 'merge') {
      'merge': { $result = libvirt::get_merged_profile($profile_hash, $base_profile) + $profile_hash[$profile] }
      'deep':  { $result = deep_merge(libvirt::get_merged_profile($profile_hash, $base_profile), $profile_hash[$profile]) }
      default: { fail('unknown profile merge function') }
    }
  }

  # remove profileconfig from the result
  $result - ['profileconfig']
}
