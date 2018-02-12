
require 'spec_helper'

describe 'libvirt::manage_domains_config' do

  let :facts do
    {
      :osfamily               => 'Debian',
      :lsbdistcodename        => 'stretch',
    }
  end

  let :default_params do
      { }
  end

  shared_examples 'libvirt::manage_domains_config shared examples' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_concat('/etc/manage-domains.ini')
      .with_owner( 'root' )
      .with_group( 'root' )
      .with_mode( '0644' )
    }

    it { is_expected.to contain_concat__fragment('/etc/manage-domains.ini header')
      .with_target( '/etc/manage-domains.ini' )
      .with_order( '01' )
    }
  end

  context 'with defaults' do
    let :params do
      default_params
    end
    it_behaves_like 'libvirt::manage_domains_config shared examples'
  end
end
