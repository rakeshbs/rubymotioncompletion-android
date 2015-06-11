class SemanticTree
  attr_accessor :snippet, :children

  def add_child(child)
    children << child unless children.include?(snippet)
  end

  def get_matches(prefix)
    index_of_colon = prefix.indexOf("::")
    match = prefix[0..(index_of_colon-1)]
    rest = prefix[(index_of_colon + 1)..-1]

  end
end
