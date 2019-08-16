
require 'spec_helper'

describe 'libvirt_generate_mac_addresses' do
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
                                     ]).and_return([
                                                     { 'network' => 'test', 'portgroup' => 'he', 'mac' => '52:54:00:d8:54:bc' },
                                                     { 'network' => 'test', 'portgroup' => 'll', 'mac' => '42:42:42:42:42:42' },
                                                     { 'network' => 'prod', 'portgroup' => 'oo', 'mac' => '52:54:00:b8:cf:03' },
                                                   ])
    }
  end
end
