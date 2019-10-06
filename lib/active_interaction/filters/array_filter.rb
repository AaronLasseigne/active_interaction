# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.array(*attributes, options = {}, &block)
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Arrays.
    #
    #   @!macro filter_method_params
    #   @param block [Proc] filter method to apply to each element
    #
    #   @example
    #     array :ids
    #   @example
    #     array :ids do
    #       integer
    #     end
    #   @example
    #     array :ids do
    #       integer default: nil
    #     end
  end

  # @private
  class ArrayFilter < Filter
    include Missable

    register :array

    private

    def klasses
      %w[
        ActiveRecord::Relation
        ActiveRecord::Associations::CollectionProxy
      ].each_with_object([Array]) do |name, result|
        next unless (klass = name.safe_constantize)

        result.push(klass)
      end
    end

    def matches?(value)
      klasses.any? { |klass| value.is_a?(klass) }
    end

    def adjust_output(value, context)
      return value if filters.empty?

      filter = filters.values.first
      value.map { |e| filter.clean(e, context) }
    end

    def convert(value)
      if value.respond_to?(:to_ary)
        value.to_ary
      else
        value
      end
    end

    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(*, &block)
      super do |klass, names, options|
        filter = klass.new(name.to_s.singularize.to_sym, options, &block)

        validate!(filter, names)

        filters[filter.name] = filter
      end
    end
    # rubocop:enable Style/MissingRespondToMissing

    # @param filter [Filter]
    # @param names [Array<Symbol>]
    #
    # @raise [InvalidFilterError]
    def validate!(filter, names)
      unless filters.empty?
        raise InvalidFilterError, 'multiple filters in array block'
      end

      unless names.empty?
        raise InvalidFilterError, 'attribute names in array block'
      end

      if filter.default?
        raise InvalidDefaultError, 'default values in array block'
      end

      nil
    end
  end
end
