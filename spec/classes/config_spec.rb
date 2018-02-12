
require 'spec_helper'

describe 'libvirt::config' do

  let :facts do
    {
      :osfamily        => 'Debian',
      :lsbdistcodename => 'stretch',
    }
  end

  let :default_params do
      { :qemu_conf => {},
      }
  end

  shared_examples 'libvirt::config shared examples' do
    it { is_expected.to compile.with_all_deps }

  end

  context 'with defaults' do
    let :params do
      default_params
    end
    it_behaves_like 'libvirt::config shared examples'
  end

  context 'with qemu_hook' do
    let :params do
      default_params.merge(
        :qemu_hook => 'drbd',
      )
    end
    it_behaves_like 'libvirt::config shared examples'
    it { is_expected.to contain_file('/etc/libvirt/hooks/qemu')
      .with_owner('root')
      .with_group('root')
      .with_mode('0755')
    }
  end

  context 'with qemu.conf' do
    let :params do
      default_params.merge(
        :qemu_conf => {'string' => 'test', 'integer' => 2, 'array' => ['A','B']},
      )
    end
    it_behaves_like 'libvirt::config shared examples'
    it { is_expected.to contain_file('/etc/libvirt/qemu.conf')
      .with_owner('root')
      .with_group('root')
      .with_mode('0600')
      .with_content(/^string = "test"$/)
      .with_content(/^integer = 2$/)
      .with_content(/^array = \["A", "B"\]$/)
    }
  end
end
