require 'spec_helper'

describe 'Libvirt::Nwfilter::Chain' do
  describe 'valid types' do
    context 'with valid types' do
      [
        'mac',
        'stp',
        'vlan',
        'arp',
        'arp-test',
        'rarp',
        'ipv4',
        'ipv6',
        'ipv4-xy',
        'ipv6-xy',
        'arp-xy',
        'rarp-xy',
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
        'ネット',
        '55555',
        'blah',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
