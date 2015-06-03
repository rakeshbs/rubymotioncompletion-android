require 'nokogiri'

class Parser

  def parse_using_children(node)
    return nil if @child_parsers.nil?
    @child_parsers.each do |child_parser|
      if child_parser.can_parse?(node)
        return child_parser.parse(node)

      end
    end
  end

  def parse(node)
  end

  def can_parse?(node)
  end

  def add_child_parser(parser)
    @child_parsers ||= []
    @child_parsers << parser.new
  end

end
