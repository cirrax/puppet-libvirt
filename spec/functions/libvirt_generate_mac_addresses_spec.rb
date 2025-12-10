# frozen_string_literal: true

require 'spec_helper'

describe 'libvirt_generate_mac_addresses' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'Without parameters' do
        it { is_expected.to run.with_params.and_raise_error(NoMethodError) }
      end

      context 'with parameters interface without mac' do
        it {
          is_expected.to run.with_params([
                                           { 'network' => 'test', 'portgroup' => 'blah' },
                                         ]).and_return([
                                                         { 'network' => 'test', 'portgroup' => 'blah', 'mac' => '52:54:00:e5:1a:3d' },
                                                       ])
        }
      end

      context 'with interface and predefined mac' do
        it {
          is_expected.to run.with_params([
                                           { 'network' => 'test', 'mac' => '42:42::42:42:42:42', 'portgroup' => 'blah' },
                                         ]).and_return([
                                                         { 'network' => 'test', 'mac' => '42:42::42:42:42:42', 'portgroup' => 'blah' },
                                                       ])
        }
      end

      context 'with multiple mixed interfaces' do
        it {
          is_expected.to run.with_params([
                                           { 'network' => 'test', 'portgroup' => 'he' },
                                           { 'network' => 'test', 'portgroup' => 'll', 'mac' => '42:42:42:42:42:42' },
                                           { 'network' => 'prod', 'portgroup' => 'oo' },
                                           { 'network' => 'nopo' },
                                         ]).and_return([
                                                         { 'network' => 'test', 'portgroup' => 'he', 'mac' => '52:54:00:d8:54:bc' },
                                                         { 'network' => 'test', 'portgroup' => 'll', 'mac' => '42:42:42:42:42:42' },
                                                         { 'network' => 'prod', 'portgroup' => 'oo', 'mac' => '52:54:00:b8:cf:03' },
                                                         { 'network' => 'nopo', 'mac' => '52:54:00:14:ec:f8' },
                                                       ])
        }
      end

      context 'with interface source and predefined mac' do
        it {
          is_expected.to run.with_params([
                                           { 'source' => { 'network' => 'test' }, 'mac' => '42:42::42:42:42:42' },
                                         ]).and_return([
                                                         { 'source' => { 'network' => 'test' }, 'mac' => '42:42::42:42:42:42' },
                                                       ])
        }
      end

      context 'with multiple mixed source interfaces' do
        it {
          is_expected.to run.with_params([
                                           { 'source' => { 'network' => 'test', 'portgroup' => 'he' } },
                                           { 'source' => { 'network' => 'test', 'portgroup' => 'll' }, 'mac' => '42:42:42:42:42:42' },
                                           { 'source' => { 'network' => 'prod', 'portgroup' => 'oo' } },
                                           { 'source' => { 'network' => 'nopo' } },
                                         ]).and_return([
                                                         { 'source' => { 'network' => 'test', 'portgroup' => 'he' }, 'mac' => '52:54:00:d8:54:bc' },
                                                         { 'source' => { 'network' => 'test', 'portgroup' => 'll' }, 'mac' => '42:42:42:42:42:42' },
                                                         { 'source' => { 'network' => 'prod', 'portgroup' => 'oo' }, 'mac' => '52:54:00:b8:cf:03' },
                                                         { 'source' => { 'network' => 'nopo' }, 'mac' => '52:54:00:14:ec:f8' },
                                                       ])
        }
      end

      context 'with ignoring filter rules' do
        it {
          is_expected.to run.with_params([
                                           { 'interface_type' => 'bridge', 'source' => { 'bridge' => 'virbr0' } },
                                           { 'interface_type' => 'bridge', 'source' => { 'bridge' => 'virbr0' }, 'filter' => 'clean-traffic' },
                                           { 'interface_type' => 'user' },
                                           { 'interface_type' => 'user', 'filter' => 'clean-traffic' },
                                         ]).and_return([
                                                         { 'interface_type' => 'bridge', 'source' => { 'bridge' => 'virbr0' }, 'mac' => '52:54:00:79:e5:40' },
                                                         { 'interface_type' => 'bridge', 'source' => { 'bridge' => 'virbr0' }, 'filter' => 'clean-traffic', 'mac' => '52:54:00:79:e5:40' },
                                                         { 'interface_type' => 'user', 'mac' => '52:54:00:12:36:36' },
                                                         { 'interface_type' => 'user', 'filter' => 'clean-traffic', 'mac' => '52:54:00:12:36:36' },
                                                       ])
        }
      end
    end
  end
end
