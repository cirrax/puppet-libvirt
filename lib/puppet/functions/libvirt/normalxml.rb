# frozen_string_literal: true

File.expand_path('../../..', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }

# require_relative '../../../puppet_x/libvirt/rexml_sorted_attributes.rb'
require 'puppet_x/libvirt/rexml_sorted_attributes.rb'
require 'puppet_x/libvirt/sort_elements.rb'

# @summary
#   normalize a xml string
#
# For the providers to compare the xml string it needs exact matching.
# this function does the same for the input as it is done with the
# output of the dumpxml in the provider. (see resource libvirt_nwfilter)
#
Puppet::Functions.create_function(:"libvirt::normalxml") do
  # @param value
  #   the xml string
  #
  # @return [String]
  #   the normalized xml string.
  dispatch :normalxml do
    param 'String', :value
    return_type 'String'
  end

  # the function below is called by puppet and and must match
  # the name of the puppet function above. You can set your
  # required parameters below and puppet will enforce these
  # so change x to suit your needs although only one parameter is required
  # as defined in the dispatch method.
  def normalxml(value)
    begin
      xml = REXML::Document.new(value)
    rescue REXML::ParseException => msg
      raise Puppet::ParseError, "libvirt::normalxml: cannot parse xml: #{msg}"
    end

    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    output = ''.dup
    formatter.write(recursive_sort(xml.root), output)
    output
  end
end
