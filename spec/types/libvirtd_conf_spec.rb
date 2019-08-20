require 'spec_helper'

describe 'libvirtd_conf' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:title) { 'libvirtd-conf' }

      context 'with default provider' do
        it { is_expected.to be_valid_type.with_properties('ensure') }
        it { is_expected.to be_valid_type.with_properties('value') }

        it { is_expected.to be_valid_type.with_parameters('secret') }
      end
    end
  end
end
