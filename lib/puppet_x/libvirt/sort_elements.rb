#
# @summary function which recursivly sorts
#           the elements by name of an XML tree.
#           it also removes text elements which only have speces
#           (no text).
#
def recursive_sort(elements)
  if elements.has_elements?
    # Materialize first and sort by a flat String key 
    # to avoid JRuby Enumerable.sort_by recursion
    els = elements.elements.to_a
    els.sort! { |a, b| a.name.to_s <=> b.name.to_s }
    els.each do |element|
      # remove text with only space
      elements.elements.delete(element)
      element.each do |child|
        if (child.class == REXML::Text) && %r{^\s*$}.match?(child.to_s)
          element.delete(child)
        end
      end
      if %r{^\s*$}.match?(element.text)
        element.delete element.get_text
      end
      elements.elements.add(recursive_sort(element))
    end
  end
  elements
end
