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
        return value if filters.empty?

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

        raise InvalidFilter.new('multiple nested filters') unless filters.empty?
        raise InvalidFilter.new('nested name') unless names.empty?
        raise InvalidDefault.new('nested default') if filter.optional?

        @filters << filter
      end
    end
  end
end
