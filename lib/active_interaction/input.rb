# frozen_string_literal: true

module ActiveInteraction
  # Represents a processed input.
  class Input
    def initialize(value:, error:)
      @value = value
      @error = error
    end

    attr_reader :value, :error
  end
end
