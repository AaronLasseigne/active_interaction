module ActiveInteraction
  class ArrayFilter < Filter
    include MethodMissing

    # @param value [Object]
    #
    # @return [Array<Object>]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when Array
        return value if filters.none?

        filter = filters.first
        value.map { |e| filter.clean(e) }
      else
        super
      end
    end

    private

    def method_missing(*args, &block)
      super do |klass, names, options|
        filter = klass.new(name, options, &block)

        raise InvalidFilter, 'multiple nested filters' if filters.any?
        raise InvalidFilter, 'nested name' unless names.empty?
        raise InvalidDefault, 'nested default' if filter.has_default?

        filters.add(filter)
      end
    end
  end
end
