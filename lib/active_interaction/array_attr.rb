module ActiveInteraction
  module ArrayAttr
    extend Attr

    def self.prepare(_, value, options = {}, &block)
      case value
        when Array
          convert_values(value, &block)
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end

    def self.convert_values(values, &block)
      return values.dup unless block_given?

      attr_methods = ActiveInteraction::AttrMethods.evaluate(&block)
      if attr_methods.count > 1
        raise ArgumentError
      else
        attr_method = attr_methods.first
      end

      values.map do |value|
        ActiveInteraction::Attr.factory(attr_method.method_name).prepare(attr_method.attribute, value, attr_method.options, &attr_method.block)
      end
    end
    private_class_method :convert_values
  end
end
