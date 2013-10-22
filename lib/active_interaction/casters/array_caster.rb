module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Arrays.
    #
    # @macro attribute_method_params
    # @param block [Proc] A filter method to apply to each element.
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
    #     integer allow_nil: true
    #   end
    #
    # @method self.array(*attributes, options = {}, &block)
  end

  # @private
  class ArrayCaster < Caster
    def self.prepare(filter, value)
      case value
        when Array
          convert_values(value, &filter.block)
        else
          super
      end
    end

    def self.convert_values(values, &block)
      return values.dup unless block_given?

      filter = get_filter(Filters.evaluate(&block))
      values.map do |value|
        Caster.cast(filter, value)
      end
    rescue InvalidValue, MissingValue
      raise InvalidNestedValue
    end
    private_class_method :convert_values

    def self.get_filter(filters)
      if filters.count > 1
        raise ArgumentError, 'Array filter blocks can only contain one filter.'
      else
        filters.first
      end
    end
    private_class_method :get_filter
  end
end
