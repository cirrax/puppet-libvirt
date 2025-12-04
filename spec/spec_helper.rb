# frozen_string_literal: true

require 'rspec/core'
require 'voxpupuli/test/spec_helper'

Dir['./spec/support/spec/**/*.rb'].sort.each { |f| require f }
