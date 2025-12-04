# frozen_string_literal: true

require 'spec_helper'

describe 'libvirt_generate_uuid' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with parameters' do
        it { is_expected.to run.with_params('generate a uuid').and_return('ccb5557f-4aea-b88d-1a57-be7b3909e216') }
        it { is_expected.to run.with_params('generate another uuid').and_return('57ca0a6e-d282-38a4-24fe-e7c8eb1c89b8') }
      end
    end
  end
end
