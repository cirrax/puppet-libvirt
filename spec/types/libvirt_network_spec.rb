require 'spec_helper'

describe 'libvirt_network' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:title) { 'libvirt-network' }

      context 'with default provider' do
        it { is_expected.to be_valid_type.with_properties('ensure') }
        it { is_expected.to be_valid_type.with_properties('active') }
        it { is_expected.to be_valid_type.with_properties('autostart') }
        it { is_expected.to be_valid_type.with_properties('content') }

        it { is_expected.to be_valid_type.with_parameters('name') }
        it { is_expected.to be_valid_type.with_parameters('uuid') }
        it { is_expected.to be_valid_type.with_parameters('show_diff') }
      end
    end
  end
end
