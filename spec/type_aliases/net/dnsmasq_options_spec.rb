require 'spec_helper'

describe 'Libvirt::Net::Dnsmasq_options' do
  describe 'valid types' do
    context 'with valid types' do
      [
        [{ 'dnsmasq:option' => { 'value' => 'foo=bar' } }],
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
