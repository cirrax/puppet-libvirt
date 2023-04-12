
require 'spec_helper'

describe 'libvirt::install' do
  let :default_params do
    {
      packages: ['qemu', 'libvirt-daemon-system', 'libvirt-bin'],
      qemu_hook_packages: { drbd: ['xmlstarlet', 'python-libvirt'] },
      package_ensure: 'installed',
    }
  end

  shared_examples 'libvirt::install shared examples' do
    it { is_expected.to compile.with_all_deps }
    it {
      params[:packages].each do |package|
        is_expected.to contain_package(package)
          .with_ensure(params[:package_ensure])
      end
    }
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
          params[:qemu_hook_packages][:drbd].each do |package|
            is_expected.not_to contain_package(package)
          end
        }
      end

      context 'with package ensure non default' do
        let :params do
          default_params.merge(
            package_ensure: 'actual',
            packages: [ 'libvirt-clients', 'libvirt', 'qemu-kvm', 'qemu-system-x86'],
          )
        end

        it_behaves_like 'libvirt::install shared examples'
      end

      context 'with drbd hook' do
        # hook_packages=hiera.lookup('libvirt::install::qemu_hook_packages', nil, nil)
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

        it {
          params[:qemu_hook_packages][:drbd].each do |package|
            is_expected.to contain_package(package)
              .with_ensure(params[:package_ensure])
          end
        }
      end
    end
  end
end
