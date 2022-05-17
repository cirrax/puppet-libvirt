require 'spec_helper'

describe 'Libvirt::Net::Route' do
  describe 'valid types' do
    context 'with valid types' do
      [
        { 'address' => '42.42.42.42', 'prefix' => '24', 'gateway' => '12.12.12.1' },
        { 'family' => 'ipv6', 'address' => '2001:db8:ca2:3', 'prefix' => '64', 'gateway' => '2001:db8:ca2:2::2', 'metric' => 2 },
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
        '',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
