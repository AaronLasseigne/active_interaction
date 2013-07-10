module ActiveInteraction
  # @private
  class AttrMethod
    attr_reader :method_name, :attribute, :options, :block

    def initialize(method_name, *args, &block)
      @method_name, @block = method_name, block

      @attribute = args.shift if args.first.is_a?(Symbol)
      @options   = (args.first || {}).dup
    end
  end
end
