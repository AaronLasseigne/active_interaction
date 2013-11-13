module ActiveInteraction
  class HashInput < Input
    # @param value [Object]
    #
    # @return [Hash{Symbol => Object}]
    #
    # @raise (see Input#cast)
    def cast(value)
      case value
      when Hash
        inputs.reduce({}) do |h, f|
          k = f.name
          h[k] = f.clean(value[k])
          h
        end
      else
        super
      end
    end

    def method_missing(*args, &block)
      begin
        klass = self.class.factory(args.first)
      rescue MissingInput
        super
      end

      args.shift
      options = args.last.is_a?(Hash) ? args.pop : {}

      # TODO: Better error.
      raise Error if args.empty?

      args.each do |name|
        @inputs << klass.new(name, options)
      end
    end
  end
end
