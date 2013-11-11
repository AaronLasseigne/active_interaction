module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Hashes.
    #
    # @param *attributes [Symbol] One or more attributes to create.
    # @param options [Hash]
    # @option options [Boolean] :allow_nil Allow a `nil` value.
    # @option options [Object] :default Set to `{}` to allow defaults. Defaults
    #   on keys will bubble up to populate the empty hash.
    # @param block [Proc] Filter methods to apply for select keys.
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
    # @example A Hash with default keys. If a hash is provided the key defaults are substituted for missing values.
    #   hash :order do
    #     model :account
    #     model :item
    #     integer :quantity, default: 1
    #     boolean :delivered, default: false
    #   end
    #
    # @example A Hash with a default. If nothing is passed the key defaults will be returned or an empty hash if there are no key defaults.
    #   hash :order, default: {} do
    #     integer :quantity, default: 1
    #     boolean :delivered, default: false
    #   end
    #
    # @method self.hash(*attributes, options = {}, &block)
  end

  # @private
  class HashFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when Hash
          convert_values(value, &block)
        else
          super
      end
    end

    def self.convert_values(hash, &block)
      return hash unless block_given?

      FilterMethods.evaluate(&block).each do |method|
        key = method.attribute
        hash[key] = Filter.factory(method.method_name).
          prepare(key, hash[key], method.options, &method.block)
      end

      hash
    rescue InvalidValue, MissingValue
      raise InvalidNestedValue
    end
    private_class_method :convert_values
  end
end
