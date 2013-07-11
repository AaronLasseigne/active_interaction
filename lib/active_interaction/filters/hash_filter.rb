module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Hashes.
    #
    # @macro attribute_method_params
    # @param block [Proc] Filter methods to apply for selected keys.
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
          convert_values(value.dup, &block)
        else
          super
      end
    end

    def self.convert_values(hash, &block)
      return hash unless block_given?

      FilterMethods.evaluate(&block).each do |filter_method|
        key = filter_method.attribute

        hash[key] = Filter.factory(filter_method.method_name).prepare(key, hash[key], filter_method.options, &filter_method.block)
      end

      hash
    end
    private_class_method :convert_values
  end
end
