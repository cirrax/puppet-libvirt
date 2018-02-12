
require 'spec_helper'

describe 'libvirt::service' do

  let :facts do
    {
      :osfamily               => 'Debian',
      :lsbdistcodename        => 'stretch',
    }
  end

  let :default_params do
      { :service_name   => 'libvirtd',
	:service_ensure => 'running',
	:service_enable => true,
      }
  end

  shared_examples 'libvirt::service shared examples' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_service('libvirtd')
      .with_name( params[:service_name] )
      .with_ensure( params[:service_ensure] )
      .with_enable( params[:service_enable] )
    }
  end

  context 'with defaults' do
    let :params do
      default_params
    end
    it_behaves_like 'libvirt::service shared examples'
  end

  context 'with non defaults' do
    let :params do
      default_params.merge( 
        :service_ensure => 'stopped',
        :service_enable => false,
        :service_name   => 'dtrivbil',
      )
    end
    it_behaves_like 'libvirt::service shared examples'
  end
end
