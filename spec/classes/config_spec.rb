
require 'spec_helper'

describe 'libvirt::config' do
  let :default_params do
    { qemu_conf: {},
      uri_aliases: [],
      uri_default: '',
      default_conf: {},
      libvirtd_conf: {} }
  end

  shared_examples 'libvirt::config shared examples' do
    it { is_expected.to compile.with_all_deps }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        let :params do
          default_params
        end

        it_behaves_like 'libvirt::config shared examples'

        it { is_expected.not_to contain_file('/etc/libvirt/libvirt.conf') }
      end

      context 'with qemu_hook' do
        let :params do
          default_params.merge(
            qemu_hook: 'drbd',
          )
        end

        it_behaves_like 'libvirt::config shared examples'
        it {
          is_expected.to contain_file('/etc/libvirt/hooks/qemu')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
        }
      end

      context 'with qemu.conf' do
        let :params do
          default_params.merge(
            qemu_conf: { 'string' => 'test', 'integer' => 2, 'array' => ['A', 'B'] },
          )
        end

        it_behaves_like 'libvirt::config shared examples'
        it {
          is_expected.to contain_file('/etc/libvirt/qemu.conf')
            .with_owner('root')
            .with_group('root')
            .with_mode('0600')
            .with_content(%r{^string = "test"$})
            .with_content(%r{^integer = 2$})
            .with_content(%r{^array = \["A", "B"\]$})
        }
      end

      context 'with uri_aliases' do
        let :params do
          default_params.merge(
            uri_aliases: ['te=qemu:///system', 'hail=qemu+ssh://root@hail.cloud.example.com/system'],
          )
        end

        it_behaves_like 'libvirt::config shared examples'
        it {
          is_expected.to contain_file('/etc/libvirt/libvirt.conf')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
        }
      end

      context 'with uri_default' do
        let :params do
          default_params.merge(
            uri_default: 'qemu:///system',
          )
        end

        it_behaves_like 'libvirt::config shared examples'
        it {
          is_expected.to contain_file('/etc/libvirt/libvirt.conf')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
        }
      end
    end
  end
end
