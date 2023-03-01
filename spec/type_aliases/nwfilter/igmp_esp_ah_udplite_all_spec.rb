require 'spec_helper'

describe 'Libvirt::Nwfilter::Protocol::Igmp_esp_ah_udplite_all' do
  describe 'valid types' do
    context 'with valid types' do
      [
        { 'id' => 'all',
          'match' => 'no', },
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        true,
        false,
        :keyword,
        nil,
        { 'foo' => 'bar' },
        {},
        [],
        '',
        'blah',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
