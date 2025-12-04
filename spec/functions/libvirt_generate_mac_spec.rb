# frozen_string_literal: true

require 'spec_helper'

describe 'libvirt_generate_mac' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with parameters' do
        it { is_expected.to run.with_params('www.cirrax.com').and_return('52:54:00:21:49:55') }
        it { is_expected.to run.with_params('www.cirrax.com', '10.10.10.10').and_return('52:54:00:76:3a:72') }
      end
    end
  end
end
