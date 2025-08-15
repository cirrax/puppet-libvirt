# REXML module with sorted attributes so we have a deterministic output
#
require 'rexml/document'

# replace each_attribute with a sorted version
class REXML::Attributes
  alias xx_each_attribute each_attribute
  def each_attribute_sorted(&b)
    return enum_for(:each_attribute_sorted) unless block_given?
    # Materialize to a plain array first (avoid nested enumerators), then sort by a flat String key.
    attrs = to_enum(:xx_each_attribute).to_a
    attrs.sort! { |a, b| a.name.to_s <=> b.name.to_s }
    attrs.each(&b)
  end
end
