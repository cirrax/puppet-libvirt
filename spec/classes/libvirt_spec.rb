
require 'spec_helper'

describe 'libvirt' do
  let :default_params do
    { service_name: 'libvirtd',
      manage_service: true,
      libvirt_package_names: ['libvirt-daemon-system', 'qemu'],
      qemu_conf: {},
      qemu_hook_packages: { 'drbd' => ['xmlstarlet', 'python-libvirt'] },
      create_networks: {},
      create_domains: {},
      evacuation: 'migrate',
      max_job_time: '120',
      suspend_multiplier: '5',
      uri_aliases: [],
      uri_default: '',
      default_conf: {},
      libvirtd_conf: {} }
  end

  shared_examples 'libvirt shared examples' do
    it { is_expected.to compile.with_all_deps }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        let :params do
          default_params
        end

        it_behaves_like 'libvirt shared examples'
      end

      context 'with drbd qemu_hook' do
        let :params do
          default_params.merge(
            qemu_hook: 'drbd',
          )
        end

        it_behaves_like 'libvirt shared examples'

        it { is_expected.to contain_class('libvirt::manage_domains_config') }
      end

      context 'with create_networks' do
        let :params do
          default_params.merge(
            create_networks: { 'mynetwork' => { 'bridge' => 'test' } },
          )
        end

        it_behaves_like 'libvirt shared examples'

        it {
          is_expected.to contain_libvirt__network('mynetwork')
            .with_bridge('test')
        }
      end

      context 'with create_domain' do
        let :params do
          default_params.merge(
            create_domains: { 'mydom' => { 'devices_profile' => 'myprofile' } },
          )
        end

        it_behaves_like 'libvirt shared examples'

        it {
          is_expected.to contain_libvirt__domain('mydom')
            .with_devices_profile('myprofile')
        }
      end

      context 'with manage_service false' do
        let :params do
          default_params.merge(
            manage_service: false,
          )
        end

        it_behaves_like 'libvirt shared examples'
        it { is_expected.not_to contain_service('libvirtd') }
      end

      context 'with diff_dir' do
        let :params do
          default_params.merge(
            diff_dir: '/tmp/test',
          )
        end

        it_behaves_like 'libvirt shared examples'
        it {
          is_expected.to contain_file('/tmp/test')
            .with_ensure('directory')
            .with_purge(true)
            .with_recurse(true)
        }
        it {
          is_expected.to contain_file('/tmp/test/domains')
            .with_ensure('directory')
            .with_purge(true)
            .with_recurse(true)
        }
        it {
          is_expected.to contain_file('/tmp/test/networks')
            .with_ensure('directory')
            .with_purge(true)
            .with_recurse(true)
        }
        it {
          is_expected.to contain_file('/tmp/test/nwfilters')
            .with_ensure('directory')
            .with_purge(true)
            .with_recurse(true)
        }
      end
    end
  end
end
