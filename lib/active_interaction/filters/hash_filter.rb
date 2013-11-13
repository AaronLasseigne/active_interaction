module ActiveInteraction
  class HashFilter < Filter
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

    # TODO: Extract common code between ArrayFilter, Base and this.
    def method_missing(*args, &block)
      begin
        klass = self.class.factory(args.first)
      rescue MissingFilter
        super
      end

      args.shift
      options = args.last.is_a?(Hash) ? args.pop : {}

      raise InvalidFilter.new('no name') if args.empty?

      args.each do |name|
        @filters << klass.new(name, options, &block)
      end
    end
  end
end
