
require 'spec_helper'

describe 'libvirt::install' do
  let :default_params do
    {
      packages: ['qemu', 'libvirt-daemon-system'],
      qemu_hook_packages: { drbd: ['xmlstarlet', 'python-libvirt'] },
    }
  end

  shared_examples 'libvirt::install shared examples' do
    it { is_expected.to compile.with_all_deps }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        let :params do
          default_params
        end

        it_behaves_like 'libvirt::install shared examples'
        it {
          is_expected.to contain_package('libvirt-daemon-system')
            .with_ensure('installed')
        }
        it {
          is_expected.to contain_package('qemu')
            .with_ensure('installed')
        }
        it { is_expected.not_to contain_package('xmlstarlet') }
        it { is_expected.not_to contain_package('python-libvirt') }
      end

      context 'with package ensure non default' do
        let :params do
          default_params.merge(
            package_ensure: 'actual',
          )
        end

        it_behaves_like 'libvirt::install shared examples'

        it {
          is_expected.to contain_package('libvirt-daemon-system')
            .with_ensure('actual')
        }
        it {
          is_expected.to contain_package('qemu')
            .with_ensure('actual')
        }
      end

      context 'with drbd hook' do
        let :params do
          default_params.merge(
            qemu_hook: 'drbd',
            manage_domain_file: 'puppet:///modules/libvirt/dummy',
          )
        end

        it_behaves_like 'libvirt::install shared examples'
        it {
          is_expected.to contain_file('/usr/local/sbin/manage-domains')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .with_source('puppet:///modules/libvirt/dummy')
        }
        it { is_expected.to contain_package('xmlstarlet') }
        it { is_expected.to contain_package('python-libvirt') }
        #        let(:hiera_config) { 'spec/fixtures/modules/libvirt/hiera.yaml' }
        #        hiera = Hiera.new({ :config => 'spec/fixtures/modules/libvirt/hiera.yaml' })
        #        #packages = hiera.lookup('libvirt::libvirt_package_names',nil,nil)
      end
    end
  end
end
