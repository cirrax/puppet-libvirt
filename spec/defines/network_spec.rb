
require 'spec_helper'

describe 'libvirt::network' do
  let :facts do
    {
      :osfamily               => 'Debian',
      :lsbdistcodename        => 'stretch',
    }
  end

  let :default_params do
    {
      :forward_mode       => 'bridge',
      :forward_interfaces => [],
      :portgroups         => [],
      :autostart          => true,
    }
  end

  shared_examples 'libvirt::network shared examples' do

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('libvirt::params') }
  end

  context 'whith defaults' do
    let (:title) { 'mytitle' }
    let :params do
      default_params.merge(
	:bridge => 'test',
      )
    end
    it_behaves_like 'libvirt::network shared examples'

    it { is_expected.to contain_exec('libvirt-network-' + title )
        .with_provider( 'shell' )
        .with_creates( '/etc/libvirt/qemu/networks/' + title + '.xml' )
    }
    it { is_expected.to contain_exec('libvirt-network-autostart-' + title )
	.with_command( 'virsh net-autostart ' + title )
        .with_provider( 'shell' )
        .with_creates( '/etc/libvirt/qemu/networks/autostart/' + title + '.xml' )
    }

    it { is_expected.to contain_exec('libvirt-network-start-' + title )
	.with_command( 'virsh net-start ' + title )
        .with_provider( 'shell' )
    }
    it { is_expected.to_not contain_exec('libvirt-delete-network-' + title ) }
  end

  context 'whith no autostart' do
    let (:title) { 'mytitle' }

    let :params do
      default_params.merge(
	:bridge => 'test',
	:autostart => false,
      )
    end
    it_behaves_like 'libvirt::network shared examples'
    it { is_expected.to contain_exec('libvirt-network-' + title )
        .with_provider( 'shell' )
        .with_creates( '/etc/libvirt/qemu/networks/' + title + '.xml' )
    }
    it { is_expected.to_not contain_exec('libvirt-network-autostart-' + title ) }
    it { is_expected.to_not contain_exec('libvirt-network-start-' + title ) }
    it { is_expected.to_not contain_exec('libvirt-delete-network-' + title ) }
  end

  context 'whith absent' do
    let (:title) { 'mytitle' }

    let :params do
      default_params.merge(
	:ensure => 'absent',
      )
    end
    it_behaves_like 'libvirt::network shared examples'
    it { is_expected.to_not contain_exec('libvirt-network-' + title ) }
    it { is_expected.to contain_exec('libvirt-delete-network-' + title ) }
    it { is_expected.to contain_exec('libvirt-network-disable-autostart-' + title ) }
    it { is_expected.to contain_exec('libvirt-undefine-network-' + title ) }
  end
end

