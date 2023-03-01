require 'spec_helper'

describe 'Libvirt::Filterref' do
  describe 'valid types' do
    context 'with valid types' do
      [
        [{ 'filter' => 'blah' }],
        [{ 'filter' => 'blah', parameters: [ { 'TEST' => '1' }] }],
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
        'ネット',
        '55555',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
