#
# @summary function which recursivly sorts
#           the elements by name of an XML tree.
#           it also removes text elements which only have speces
#           (no text).
#
def recursive_sort(elements)
  if elements.has_elements?
    el = elements.elements.sort_by(&:name)
    el.each do |element|
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
