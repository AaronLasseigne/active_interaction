module ActiveInteraction
  class ArrayFilter < FilterWithBlock
    def method_missing(type, options = {}, &block)
      if options.is_a?(Symbol)
        raise ArgumentError, 'Array sub-filters can not be named.'
      end

      filters.add(Filter.factory(type).new(:unnamed, options.dup, &block))
    end
    private :method_missing
  end
end
