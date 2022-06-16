# frozen_string_literal: true

module ActiveInteraction
  # Represents a processed array input.
  class ArrayInput < Input
    def initialize(filter, value: nil, error: nil, index_errors: false, children: [])
      super(filter, value: value, error: error)

      @index_errors = index_errors
      @children = children
    end

    # @overload children
    #   Child inputs if a nested filter is used.
    #
    #   @return [Array<Input, ArrayInput, HashInput>]
    attr_reader :children

    def errors
      return @errors if defined?(@errors)

      return @errors = super if @error

      child_errors = get_errors_by_index(children)

      return @errors = super if child_errors.empty?

      @errors ||=
        if @index_errors
          child_errors.map do |(error, i)|
            Filter::Error.new(error.filter, error.type, name: :"#{@filter.name}[#{i}]")
          end
        else
          error, = child_errors.first
          [Filter::Error.new(@filter, error.type)]
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
  end
end
