# frozen_string_literal: true

module ActiveInteraction
  # Holds a group of inputs together for passing from {Base} to {Filter}s.
  #
  # @private
  class GroupedInput
    include Comparable

    attr_reader :data
    protected :data

    def initialize(**data)
      @data = data
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = value
    end

    def <=>(other)
      return nil unless other.is_a?(self.class)

      data <=> other.data
    end
  end
end
