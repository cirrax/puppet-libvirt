module Puppet::Parser::Functions
  newfunction(:libvirt_generate_mac, type: :rvalue) do |args|
    # compute sha1 hash of all keys concatenated, only the first 6
    # hex digits will be used
    sha1 = Digest::SHA1.hexdigest(args.join(''))

    # generate address in the QEMU/KVM MAC OID
    '52:54:00:' + "#{sha1[0..1]}:#{sha1[2..3]}:#{sha1[4..5]}"
  end
end
