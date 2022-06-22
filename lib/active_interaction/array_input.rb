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
    def errors
      return @errors if defined?(@errors)

      return @errors = super if @error

      child_errors = get_errors_by_index(children)

      return @errors = super if child_errors.empty?

      @errors ||=
        if @index_errors
          child_errors.map do |(error, i)|
            name = attach_child_name(:"#{@filter.name}[#{i}]", error)
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

    def attach_child_name(name, error)
      return name unless error.name.present?

      if children_are_arrays?(children)
        :"#{name}#{error.name.to_s.sub(/\A[^\[]*/, '')}"
      elsif children_are_hashes?(children)
        :"#{name}.#{error.name.to_s[1..]}"
      end
    end

    def children_are_arrays?(children)
      return @children_are_arrays if defined?(@children_are_arrays)

      @children_are_arrays = children.first&.is_a?(ArrayInput)
    end

    def children_are_hashes?(children)
      return @children_are_hashes if defined?(@children_are_hashes)

      @children_are_hashes = children.first&.is_a?(HashInput)
    end
  end
end
