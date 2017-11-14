
require 'spec_helper'

describe 'libvirt_generate_mac' do

  context "with parameters" do
    it { should run.with_params('www.cirrax.com').and_return('52:54:00:21:49:55') }
    it { should run.with_params('www.cirrax.com', '10.10.10.10').and_return('52:54:00:76:3a:72') }
  end
end

