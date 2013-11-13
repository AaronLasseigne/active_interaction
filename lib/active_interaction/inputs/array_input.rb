module ActiveInteraction
  class ArrayInput < Input
    # @param value [Object]
    #
    # @return [Array<Object>]
    #
    # @raise (see Input#cast)
    def cast(value)
      case value
      when Array
        return value if inputs.empty?

        input = inputs.first
        value.map { |e| input.clean(e) }
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

      options = args.last.is_a?(Hash) ? args.pop : {}
      input = klass.new(name, options, &block)

      # TODO: Better errors.
      raise Error unless inputs.empty?
      raise Error if args.length > 1
      raise Error if input.optional?

      @inputs << input
    end
  end
end
