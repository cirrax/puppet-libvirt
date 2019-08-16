
require 'spec_helper'

describe 'libvirt::profiles' do
  shared_examples 'libvirt::profiles shared examples' do
    it { is_expected.to compile.with_all_deps }
  end

  context 'with defaults' do
    it_behaves_like 'libvirt::profiles shared examples'
  end
end
