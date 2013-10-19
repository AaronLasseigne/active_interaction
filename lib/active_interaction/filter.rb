module ActiveInteraction
  # @private
  class Filter
    attr_reader :type, :name, :options, :block

    def initialize(type, name, options = {}, &block)
      @type, @name, @options, @block = type, name, options.dup, block
    end
  end
end
