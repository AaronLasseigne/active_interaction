# frozen_string_literal: true

module ActiveInteraction
  # Represents a processed hash input.
  class HashInput < Input
    # @private
    def initialize(filter, value: nil, error: nil, children: {})
      super(filter, value: value, error: error)

      @children = children
    end

    # @overload children
    #   Child inputs if nested filters are used.
    #
    #   @return [Hash{ Symbol => Input, ArrayInput, HashInput }]
    attr_reader :children

    # Any errors that occurred during processing.
    #
    # @return [Filter::Error]
    def errors
      return @errors if defined?(@errors)

      return @errors = super if @error

      child_errors = get_errors(children)

      return @errors = super if child_errors.empty?

      @errors ||=
        child_errors.map do |error|
          Filter::Error.new(error.filter, error.type, name: :"#{@filter.name}.#{error.name}")
        end.freeze
    end

    private

    def get_errors(children)
      children.values.flat_map(&:errors)
    end
  end
end
