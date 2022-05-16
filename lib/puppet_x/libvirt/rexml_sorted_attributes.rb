# REXML module with sorted attributes so we have a deterministic output
#
require 'rexml/document'

# replace each_attribute with a sorted version
class REXML::Attributes
  alias xx_each_attribute each_attribute
  def each_attribute(&b)
    to_enum(:xx_each_attribute).sort_by { |x| x.name }.each(&b)
  end
end
