
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

  context 'with defaults' do
    let :params do
      default_params.merge(
        :qemu_hook => 'drbd',
      )
    end
    it_behaves_like 'libvirt shared examples'

    it { is_expected.to contain_class('libvirt::manage_domains_config') }
  end
end
