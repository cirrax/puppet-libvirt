
require 'spec_helper'

describe 'libvirt::params' do
  let :facts do
    {
      :osfamily               => 'Debian',
      :lsbdistcodename        => 'stretch',
    }
  end

  it { is_expected.to compile.with_all_deps }
end

