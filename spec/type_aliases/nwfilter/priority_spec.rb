require 'spec_helper'

describe 'Libvirt::Nwfilter::Priority' do
  describe 'valid types' do
    context 'with valid types' do
      [
        0,
        1000,
        -1000,
        999,
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
        '-4242',
        'blah',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
