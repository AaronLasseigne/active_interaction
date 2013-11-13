module ActiveInteraction
  class HashFilter < Filter
    include MethodMissing

    # @param value [Object]
    #
    # @return [Hash{Symbol => Object}]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when Hash
        filters.reduce({}) do |h, f|
          k = f.name
          h[k] = f.clean(value[k])
          h
        end
      else
        super
      end
    end

    private

    def method_missing(*args, &block)
      super do |klass, names, options|
        raise InvalidFilter.new('no name') if names.empty?

        names.each do |name|
          @filters << klass.new(name, options, &block)
        end
      end
    end
  end
end
