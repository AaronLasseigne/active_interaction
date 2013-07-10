module ActiveInteraction
  # @private
  class HashAttr < Attr
    def self.prepare(_, value, options = {}, &block)
      case value
        when Hash
          convert_values(value.dup, &block)
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end

    def self.convert_values(hash, &block)
      return hash unless block_given?

      AttrMethods.evaluate(&block).each do |attr_method|
        key = attr_method.attribute

        hash[key] = Attr.factory(attr_method.method_name).prepare(key, hash[key], attr_method.options, &attr_method.block)
      end

      hash
    end
    private_class_method :convert_values
  end
end
