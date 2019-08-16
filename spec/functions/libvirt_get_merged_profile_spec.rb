
require 'spec_helper'

describe 'libvirt::get_merged_profile' do
  context 'with parameters' do
    it { is_expected.to run.with_params({}, 'default').and_return({}) }
  end
end
