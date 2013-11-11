module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Hashes.
    #
    # @macro attribute_method_params
    # @param block [Proc] Filters to apply for select keys.
    #
    # @example
    #   hash :order
    #
    # @example A Hash where certain keys also have their values ensured.
    #   hash :order do
    #     model :account
    #     model :item
    #     integer :quantity
    #     boolean :delivered
    #   end
    #
    # @method self.hash(*attributes, options = {}, &block)
  end

  # @private
  class HashCaster < Caster
    def self.prepare(filter, value)
      case value
        when Hash
          sub_prepare(filter.filters, value.merge(filter.options[:default] || {}))
        else
          super
      end
    end

    def self.sub_prepare(filters, value)
      return value if filters.none?

      filters.each do |filter|
        key = filter.name
        value[key] = Caster.cast(filter, value[key])
      end

      value
    rescue InvalidValue, MissingValue
      raise InvalidNestedValue
    end
    private_class_method :sub_prepare
  end
end
