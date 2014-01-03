# coding: utf-8

module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Arrays.
    #
    # @macro filter_method_params
    # @param block [Proc] filter method to apply to each element
    #
    # @example
    #   array :ids
    #
    # @example An Array of Integers
    #   array :ids do
    #     integer
    #   end
    #
    # @example An Array of Integers where some or all are nil
    #   array :ids do
    #     integer default: nil
    #   end
    #
    # @since 0.1.0
    #
    # @method self.array(*attributes, options = {}, &block)
  end

  # @private
  class ArrayFilter < Filter
    include MethodMissing

    def cast(value)
      case value
      when Array
        return value if filters.none?

        filter = filters.first
        value.map { |e| filter.clean(e) }
      else
        super
      end
    end

    def method_missing(*_, &block)
      super do |klass, names, options|
        filter = klass.new(name, options, &block)

        validate(filter, names)

        filters.add(filter)
      end
    end

    private

    def validate(filter, names)
      if filters.any?
        fail InvalidFilterError, 'multiple filters in array block'
      end

      unless names.empty?
        fail InvalidFilterError, 'attribute names in array block'
      end

      if filter.has_default?
        fail InvalidDefaultError, 'default values in array block'
      end
    end
  end
end
