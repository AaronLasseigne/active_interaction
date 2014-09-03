# coding: utf-8

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

    def clean(value, instance)
      value = super

      return value unless value.is_a? Array
      return value if filters.empty?

      filter = filters.values.first
      value.map { |e| filter.clean(e, instance) }
    end

    def cast(value)
      case value
      when Array
        value
      else
        super
      end
    end

    def method_missing(*, &block)
      super do |klass, names, options|
        filter = klass.new(name, options, &block)

        validate(filter, names)

        filters[name] = filter
      end
    end

    private

    # @param filter [Filter]
    # @param names [Array<Symbol>]
    #
    # @raise [InvalidFilterError]
    def validate(filter, names)
      unless filters.empty?
        fail InvalidFilterError, 'multiple filters in array block'
      end

      unless names.empty?
        fail InvalidFilterError, 'attribute names in array block'
      end

      # rubocop:disable GuardClause
      if filter.default?
        fail InvalidDefaultError, 'default values in array block'
      end
      # rubocop:enable GuardClause
    end
  end
end
