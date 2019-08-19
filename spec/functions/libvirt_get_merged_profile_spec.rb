
require 'spec_helper'

describe 'libvirt::get_merged_profile' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with parameters' do
        it { is_expected.to run.with_params({}, 'default').and_return({}) }
      end
    end
  end
end
