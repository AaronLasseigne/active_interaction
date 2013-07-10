module ActiveInteraction
  # @private
  class ModelAttr < Attr
    def self.prepare(key, value, options = {})
      key_class = constantize(options.fetch(:class, key))

      case value
        when key_class
          value
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end

    def self.constantize(constant_name)
      if constant_name.is_a?(Symbol) || constant_name.is_a?(String)
        constant_name.to_s.classify.constantize
      else
        constant_name
      end
    end
    private_class_method :constantize
  end
end
