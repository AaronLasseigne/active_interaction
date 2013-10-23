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
          sub_prepare(filter.filters, value)
        else
          super
      end
    end

    def self.sub_prepare(filters, values)
      return values if filters.none?

      filter = get_filter(filters)
      values.map do |value|
        Caster.cast(filter, value)
      end
    rescue InvalidValue, MissingValue
      raise InvalidNestedValue
    end
    private_class_method :sub_prepare

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
