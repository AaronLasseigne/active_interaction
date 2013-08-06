module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Hashes.
    #
    # @macro attribute_method_params
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
    # @method self.hash(*attributes, options = {}, &block)
  end

  # @private
  class HashFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when Hash
          convert_values(value.merge(options[:default] || {}), &block)
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
    end
    private_class_method :convert_values
  end
end
