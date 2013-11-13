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
        filters.reduce(options.fetch(:strip, true) ? {} : value) do |h, f|
          k = f.name
          h[k] = f.clean(value[k])
          h
        end
      else
        super
      end
    end

    def default
      case options[:default]
      when Hash
        if options[:default].empty?
          cast({})
        else
          raise InvalidDefault, name
        end
      when NilClass
        cast(nil)
      else
        super
      end
    end

    private

    def method_missing(*args, &block)
      super do |klass, names, options|
        raise InvalidFilter, 'no name' if names.empty?

        names.each do |name|
          filters.add(klass.new(name, options, &block))
        end
      end
    end
  end
end
