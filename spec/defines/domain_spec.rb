
require 'spec_helper'

describe 'libvirt::domain' do
  let :default_params do
    { domain_title: '',
      description: '',
      boot: 'hd',
      disks: [],
      interfaces: [],
      autostart: true }
  end

  shared_examples 'libvirt::domain shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_exec('libvirt-domain-' + title)
        .with_provider('shell')
        .with_creates('/etc/libvirt/qemu/' + title + '.xml')
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'whith defaults' do
        let(:title) { 'mytitle' }
        let :params do
          default_params.merge(
            autostart: true,
          )
        end

        it_behaves_like 'libvirt::domain shared examples'

        it {
          is_expected.to contain_exec('libvirt-domain-autostart-' + title)
            .with_command('virsh autostart ' + title)
            .with_provider('shell')
            .with_creates('/etc/libvirt/qemu/autostart/' + title + '.xml')
        }

        it {
          is_expected.to contain_exec('libvirt-domain-start-' + title)
            .with_command('virsh start ' + title)
            .with_provider('shell')
        }
      end

      context 'whith no autostart' do
        let(:title) { 'mytitle' }

        let :params do
          default_params.merge(
            autostart: false,
          )
        end

        it_behaves_like 'libvirt::domain shared examples'
        it { is_expected.not_to contain_exec('libvirt-domain-autostart-' + title) }
        it { is_expected.not_to contain_exec('libvirt-domain-start-' + title) }
      end
    end
  end
end
