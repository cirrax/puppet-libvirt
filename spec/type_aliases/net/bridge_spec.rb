# frozen_string_literal: true

require 'spec_helper'

describe 'Libvirt::Net::Bridge' do
  describe 'valid types' do
    context 'with valid types' do
      [
        'test',
        { 'name' => 'test', 'delay' => 100, 'stp' => 'on', 'zone' => 'blah' },
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
