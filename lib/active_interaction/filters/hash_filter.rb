module ActiveInteraction
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
