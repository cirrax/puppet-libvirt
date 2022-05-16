# frozen_string_literal: true

require 'spec_helper'

describe 'libvirt::normalxml' do
  context 'returns XML string on valid params' do
    it { is_expected.to run.with_params('<a />').and_return('<a/>') }
    it { is_expected.to run.with_params("<a y='1' x='2'></a>").and_return("<a x='2' y='1'/>") }
    it { is_expected.to run.with_params(nil).and_raise_error(StandardError) }
  end
end
