
require 'spec_helper'

describe 'libvirt::network' do
  let :default_params do
    {
      forward_mode: 'bridge',
      forward_interfaces: [],
      portgroups: [],
      autostart: true,
    }
  end

  shared_examples 'libvirt::network shared examples' do
    it { is_expected.to compile.with_all_deps }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'whith defaults' do
        let(:title) { 'mytitle' }
        let :params do
          default_params.merge(
            bridge: 'test',
          )
        end

        it_behaves_like 'libvirt::network shared examples'
      end

      context 'whith no autostart' do
        let(:title) { 'mytitle' }

        let :params do
          default_params.merge(
            bridge: 'test',
            autostart: false,
          )
        end

        it_behaves_like 'libvirt::network shared examples'
      end

      context 'whith absent' do
        let(:title) { 'mytitle' }

        let :params do
          default_params.merge(
            ensure: 'absent',
          )
        end

        it_behaves_like 'libvirt::network shared examples'
      end
    end
  end
end
