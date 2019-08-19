
require 'spec_helper'

describe 'libvirt::nwfilter' do
  let :default_params do
    {
    }
  end

  shared_examples 'libvirt::nwfilter shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_exec('libvirt-nwfilter-' + title)
        .with_provider('shell')
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'whith defaults' do
        let(:title) { 'mytitle' }
        let :params do
          default_params.merge(
            ip: '123.123.123.123',
          )
        end

        it_behaves_like 'libvirt::nwfilter shared examples'
      end
    end
  end
end
