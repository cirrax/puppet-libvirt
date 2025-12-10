# frozen_string_literal: true

require 'spec_helper'

describe 'libvirt::domain' do
  let :default_params do
    { ensure: 'present',
      domain_title: '',
      description: '',
      boot: 'hd',
      disks: [],
      interfaces: [],
      autostart: true,
      show_diff: true,
      replace: false,
      ignore: [], }
  end

  shared_examples 'libvirt::domain shared examples' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('libvirt') }

    it {
      is_expected.to contain_libvirt_domain(title)
        .with_ensure(params[:ensure])
        .with_autostart(params[:autostart])
        .with_active(params[:active])
        .with_show_diff(params[:show_diff])
        .with_replace(params[:replace])
        .with_tag('libvirt')
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'whith defaults' do
        let(:title) { 'mytitle' }
        let :params do
          default_params.merge(
            autostart: true
          )
        end

        it_behaves_like 'libvirt::domain shared examples'
      end

      context 'whith parameters set' do
        let(:title) { 'mytitle' }

        let :params do
          default_params.merge(
            show_diff: false,
            autostart: false,
            active: true,
            ignore: ['//domain/devices/controller'],
            replace: true
          )
        end

        it_behaves_like 'libvirt::domain shared examples'
      end

      context 'whith ensure absent' do
        let(:title) { 'mytitle' }

        let :params do
          default_params.merge(
            ensure: 'absent'
          )
        end

        it_behaves_like 'libvirt::domain shared examples'
      end
    end
  end
end
