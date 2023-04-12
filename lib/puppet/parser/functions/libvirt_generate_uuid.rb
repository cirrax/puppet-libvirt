#
module Puppet::Parser::Functions
  newfunction(:libvirt_generate_uuid, type: :rvalue, doc: <<-'ENDHEREDOC') do |args|
    Return a uuid generated from an sha1 hash of all keys concatenated
    @summary
      compute sha1 hash of all keys concatenated
    @return [String]
      the computed uuid

    ENDHEREDOC

    sha1 = Digest::SHA1.hexdigest(args.join(''))

    # generate a QEMU/KVM UUID
    "#{sha1[0..7]}-#{sha1[8..11]}-#{sha1[12..15]}-#{sha1[16..19]}-#{sha1[20..31]}"
  end
end
