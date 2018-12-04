
require 'spec_helper'

describe 'libvirt::domain' do

  let :facts do
    {
      :osfamily               => 'Debian',
      :lsbdistcodename        => 'stretch',
    }
  end

  let :default_params do
    { :domain_title       => '',
      :description        => '',
      :cpus               => '1',
      :boot               => 'hd',
      :bootmenu           => true,
      :disks              => [],
      :interfaces         => [],
      :autostart          => true,
    }
  end

  shared_examples 'libvirt::domain shared examples' do

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('libvirt::params') }
    it { is_expected.to contain_exec('libvirt-domain-' + title )
        .with_provider( 'shell' )
    }
  end

  context 'whith defaults' do
    let (:title) { 'mytitle' }
    let :params do
      default_params.merge(
	:max_memory     => 1024,
	:initial_memory => 1024,
      )
    end
    it_behaves_like 'libvirt::domain shared examples'

    it { is_expected.to contain_exec('libvirt-domain-autostart-' + title )
	.with_command( 'virsh autostart ' + title )
        .with_provider( 'shell' )
    }

    it { is_expected.to contain_exec('libvirt-domain-start-' + title )
	.with_command( 'virsh start ' + title )
        .with_provider( 'shell' )
    }
  end

  context 'whith no autostart' do
    let (:title) { 'mytitle' }

    let :params do
      default_params.merge(
	:max_memory     => 1024,
	:initial_memory => 1024,
	:autostart      => false,
      )
    end
    it_behaves_like 'libvirt::domain shared examples'
    it { is_expected.to_not contain_exec('libvirt-domain-autostart-' + title ) }
    it { is_expected.to_not contain_exec('libvirt-domain-start-' + title ) }
  end
end

