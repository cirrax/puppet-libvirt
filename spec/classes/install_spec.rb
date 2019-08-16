
require 'spec_helper'

describe 'libvirt::install' do
  let :facts do
    {
      osfamily: 'Debian',
      lsbdistcodename: 'stretch',
    }
  end

  let :default_params do
    {
      packages: ['qemu', 'libvirt-daemon-system'],
    }
  end

  shared_examples 'libvirt::install shared examples' do
    it { is_expected.to compile.with_all_deps }
  end

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
end
