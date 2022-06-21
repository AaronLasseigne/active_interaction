# frozen_string_literal: true

module ActiveInteraction
  # Represents a processed input.
  class Input
    def initialize(filter, value: nil, error: nil)
      @filter = filter
      @value = value
      @error = error
    end

    # @overload value
    #   The processed input value.
    attr_reader :value

    # Any errors that occurred during processing.
    #
    # @return [Filter::Error]
    def errors
      @errors ||= Array(@error)
    end
  end
end
