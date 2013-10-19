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
    def self.prepare(key, value, options = {}, &block)
      case value
        when Array
          convert_values(value, &block)
        else
          super
      end
    end

    def self.convert_values(values, &block)
      return values.dup unless block_given?

      method = get_filter_method(FilterMethods.evaluate(&block))
      values.map do |value|
        Caster.factory(method.type).
          prepare(method.name, value, method.options, &method.block)
      end
    rescue InvalidValue, MissingValue
      raise InvalidNestedValue
    end
    private_class_method :convert_values

    def self.get_filter_method(filter_methods)
      if filter_methods.count > 1
        raise ArgumentError, 'Array filter blocks can only contain one filter.'
      else
        filter_methods.first
      end
    end
    private_class_method :get_filter_method
  end
end
