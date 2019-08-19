require 'spec_helper'

describe 'libvirt_pool' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:title) { 'vnet1' }

      context 'with default provider' do
        it { is_expected.to be_valid_type.with_provider(:virsh) }

        it { is_expected.to be_valid_type.with_properties('ensure') }
        it { is_expected.to be_valid_type.with_properties('active') }
        it { is_expected.to be_valid_type.with_properties('autostart') }

        it { is_expected.to be_valid_type.with_parameters('name') }
        it { is_expected.to be_valid_type.with_parameters('type') }
        it { is_expected.to be_valid_type.with_parameters('sourcehost') }
        it { is_expected.to be_valid_type.with_parameters('sourcepath') }
        it { is_expected.to be_valid_type.with_parameters('sourcedev') }
        it { is_expected.to be_valid_type.with_parameters('sourcename') }
        it { is_expected.to be_valid_type.with_parameters('sourceformat') }
        it { is_expected.to be_valid_type.with_parameters('target') }
        it { is_expected.to be_valid_type.with_parameters('target_owner') }
        it { is_expected.to be_valid_type.with_parameters('target_group') }
        it { is_expected.to be_valid_type.with_parameters('target_mode') }
      end
    end
  end
end
