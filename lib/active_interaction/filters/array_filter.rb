module ActiveInteraction
  class ArrayFilter < Filter
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

    def method_missing(*args, &block)
      begin
        klass = self.class.factory(args.first)
      rescue MissingFilter
        super
      end

      options = args.last.is_a?(Hash) ? args.pop : {}
      filter = klass.new(name, options, &block)

      # TODO: Better errors.
      raise Error unless filters.empty?
      raise Error if args.length > 1
      raise Error if filter.optional?

      @filters << filter
    end
  end
end
