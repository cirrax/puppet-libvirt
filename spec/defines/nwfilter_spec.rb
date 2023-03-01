
require 'spec_helper'

describe 'libvirt::nwfilter' do
  let :default_params do
    {
      chain: 'root',
      rules: [],
      filterref: [],
      publictcpservices: [],
      publicudpservices: [],
      customtcprules: [],
      customudprules: [],
      template: 'simple',
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

      context 'whith defaults simple template' do
        let(:title) { 'mytitle' }
        let :params do
          default_params.merge(
            ip: '123.123.123.123',
          )
        end

        it_behaves_like 'libvirt::nwfilter shared examples'
      end

      context 'whith generic template' do
        let(:title) { 'mytitle' }
        let :params do
          default_params.merge(
            filterref: [{ 'filter' => 'blah' }],
            template: 'generic',
          )
        end

        it_behaves_like 'libvirt::nwfilter shared examples'
      end

      context 'whith generic (filterref with parameters) template' do
        let(:title) { 'mytitle' }
        let :params do
          default_params.merge(
            filterref: [{ 'filter' => 'blah', 'parameters' => [ { 'PORT' => '22' }, { 'PORT' => '80' } ] }],
            template: 'generic',
          )
        end

        it_behaves_like 'libvirt::nwfilter shared examples'
      end
    end
  end
end
