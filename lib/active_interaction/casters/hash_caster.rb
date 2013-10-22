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
  class HashCaster < Caster
    def self.prepare(filter, value)
      case value
        when Hash
          convert_values(value.merge(filter.options[:default] || {}), &filter.block)
        else
          super
      end
    end

    def self.convert_values(hash, &block)
      return hash unless block_given?

      FilterMethods.evaluate(&block).each do |filter|
        key = filter.name
        hash[key] = Caster.factory(filter.type).prepare(filter, hash[key])
      end

      hash
    rescue InvalidValue, MissingValue
      raise InvalidNestedValue
    end
    private_class_method :convert_values
  end
end
