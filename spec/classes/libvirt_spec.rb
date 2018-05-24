
require 'spec_helper'

describe 'libvirt' do

  let :facts do
    {
      :osfamily               => 'Debian',
      :lsbdistcodename        => 'stretch',
    }
  end

  let :default_params do
      { :service_name          => 'libvirtd',
	:libvirt_package_names => ['libvirt-daemon-system', 'qemu'],
	:qemu_conf             => {},
	:qemu_hook_packages    => {'drbd' => ['xmlstarlet','python-libvirt'], },
	:create_networks       => {},
	:create_domains        => {},
	:evacuation            => 'migrate',
	:max_job_time          => '120',
	:suspend_multiplier    => '5',
        :uri_aliases           => [],
        :uri_default           => '',
        :default_conf          => {},
      }
  end

  shared_examples 'libvirt shared examples' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('libvirt::params') }
  end

  context 'with defaults' do
    let :params do
      default_params
    end
    it_behaves_like 'libvirt shared examples'
  end

  context 'with drbd qemu_hook' do
    let :params do
      default_params.merge(
        :qemu_hook => 'drbd',
      )
    end
    it_behaves_like 'libvirt shared examples'

    it { is_expected.to contain_class('libvirt::manage_domains_config') }
  end

  context 'with create_networks' do
    let :params do
      default_params.merge(
        :create_networks => { 'mynetwork' => { 'bridge' => 'test' }},
      )
    end
    it_behaves_like 'libvirt shared examples'

    it { is_expected.to contain_libvirt__network('mynetwork')
      .with_bridge('test')
    }
  end

  context 'with create_domain' do
    let :params do
      default_params.merge(
        :create_domains => { 'mydom' => { 'max_memory' => 2048 }},
      )
    end
    it_behaves_like 'libvirt shared examples'

    it { is_expected.to contain_libvirt__domain('mydom')
      .with_max_memory(2048)
    }
  end
end
