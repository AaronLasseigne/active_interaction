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

    def cast(value, context)
      case value
      when *classes
        return value if filters.empty?

        filter = filters.values.first
        value.map { |e| filter.clean(e, context) }
      else
        super
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

    private

    # @return [Array<Class>]
    def classes
      result = [Array]

      %w[
        ActiveRecord::Relation
        ActiveRecord::Associations::CollectionProxy
      ].each do |name|
        next unless (klass = name.safe_constantize)

        result.push(klass)
      end

      result
    end

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
