# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/libvirt_nwfilter'

RSpec.describe 'the libvirt_nwfilter type' do
  it 'loads' do
    expect(Puppet::Type.type(:libvirt_nwfilter)).not_to be_nil
  end
end
