# frozen_string_literal: true

require 'spec_helper'

describe 'Libvirt::Nwfilter::Param' do
  describe 'valid types' do
    context 'with valid types' do
      [
        '$AWHAT',
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
        'AHWAT',
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
