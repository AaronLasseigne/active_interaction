# frozen_string_literal: true

module ActiveInteraction
  # Represents a processed hash input.
  class HashInput < Input
    def initialize(filter, value: nil, error: nil, children: {})
      super(filter, value: value, error: error)

      @children = children
    end

    # @overload children
    #   Child inputs if nested filters are used.
    #
    #   @return [Hash{ Symbol => Input, ArrayInput, HashInput }]
    attr_reader :children
  end
end
