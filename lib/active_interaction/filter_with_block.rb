module ActiveInteraction
  # @private
  class FilterWithBlock < Filter
    attr_reader :block

    def initialize(name, options = {}, &block)
      @block = block

      super
    end
  end
end
