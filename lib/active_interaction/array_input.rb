# frozen_string_literal: true

module ActiveInteraction
  # Represents a processed array input.
  class ArrayInput < Input
    # @private
    def initialize(filter, value: nil, error: nil, index_errors: false, children: [])
      super(filter, value: value, error: error)

      @filter = filter
      @index_errors = index_errors
      @children = children
    end

    # @overload children
    #   Child inputs if a nested filter is used.
    #
    #   @return [Array<Input, ArrayInput, HashInput>]
    attr_reader :children

    # Any errors that occurred during processing.
    #
    # @return [Filter::Error]
    def errors # rubocop:disable Metrics/PerceivedComplexity
      return @errors if defined?(@errors)

      return @errors = super if @error

      child_errors = get_errors_by_index(children)

      return @errors = super if child_errors.empty?

      @errors ||=
        if @index_errors
          child_errors.map do |(error, i)|
            name = :"#{@filter.name}[#{i}]"
            name = :"#{name}.#{error.name.to_s.sub(/\A0\./, '')}" if children_are_hashes?(children)
            Filter::Error.new(error.filter, error.type, name: name)
          end.freeze
        else
          error, = child_errors.first
          [Filter::Error.new(@filter, error.type)].freeze
        end
    end

    private

    def get_errors_by_index(children)
      children.flat_map.with_index do |child, i|
        child.errors.map do |error|
          [error, i]
        end
      end
    end

    def children_are_hashes?(children)
      return @children_are_hashes if defined?(@children_are_hashes)

      @children_are_hashes = children.first&.is_a?(HashInput)
    end
  end
end
