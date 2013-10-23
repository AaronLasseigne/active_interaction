module ActiveInteraction
  class ArrayFilter < FilterWithBlock
    def method_missing(type, options = {}, &block)
      if filters.count > 0
        raise ArgumentError, 'Array filter blocks can only contain one filter.'
      end

      if options.is_a?(Symbol)
        raise ArgumentError, 'Array filter blocks can not contain named filters.'
      end

      filters.add(Filter.factory(type).new(:unnamed, options.dup, &block))
    end
    private :method_missing
  end
end
