module ActiveInteraction
  # @private
  class FilterMethod
    attr_reader :method_name, :attribute, :options, :block

    def initialize(method_name, *args, &block)
      @method_name, @block = method_name, block

      # TODO: What if there are multiple attributes?
      @attribute = args.shift if args.first.is_a?(Symbol)
      @options = (args.first || {}).dup
    end
  end
end
